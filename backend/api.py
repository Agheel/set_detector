"""FastAPI Web API for YOLO SET Detection, ready for Mobile Client integration."""

import base64
import os
from typing import Any, Dict, List
import cv2
from fastapi import FastAPI, File, HTTPException, Query, UploadFile, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse, Response
import numpy as np
from pydantic import BaseModel, Field

from set_engine.detector import (
    ICardDetector,
    MockCardDetector,
    YoloCardDetector,
    discover_weights_path,
    validate_image_security,
)
from set_engine.models import Card
from set_engine.service import SetService
from set_engine.solver import FastSetSolver
from set_engine.visualizer import SetVisualizer

# Security limits
MAX_UPLOAD_SIZE = 5 * 1024 * 1024  # 5 Megabytes maximum
ALLOWED_MAGIC_SIGNATURES = {
    b"\xff\xd8\xff": "image/jpeg",
    b"\x89PNG\r\n\x1a\n": "image/png",
    b"RIFF": "image/webp",
}

app = FastAPI(
    title="SET Game YOLO Detection API",
    description="Computer Vision Backend for SET Card Detection & Solver (Mobile-Ready)",
    version="1.0.0",
)

# Enable CORS for mobile apps and web frontends
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Compress JSON payloads to minimize mobile network transfer latency
app.add_middleware(GZipMiddleware, minimum_size=500)


def _init_default_detector() -> ICardDetector:
    """Initialize detector from SET_YOLO_WEIGHTS or weights/ dir, fallback to Mock."""
    weights_path = discover_weights_path()
    if weights_path and os.path.isfile(weights_path):
        try:
            return YoloCardDetector(weights_path=weights_path)
        except Exception:
            return MockCardDetector()
    return MockCardDetector()


active_detector: ICardDetector = _init_default_detector()
active_solver = FastSetSolver()
active_visualizer = SetVisualizer()
service = SetService(active_detector, active_solver, active_visualizer)


class CardInput(BaseModel):
    """Card attribute specification for direct solving."""
    number: int = Field(..., ge=1, le=3, description="1, 2, or 3")
    shape: int = Field(..., ge=1, le=3, description="1: Oval, 2: Diamond, 3: Squiggle")
    color: int = Field(..., ge=1, le=3, description="1: Red, 2: Green, 3: Purple")
    shading: int = Field(..., ge=1, le=3, description="1: Solid, 2: Striped, 3: Open")


class SolveRequest(BaseModel):
    """Direct solver payload."""
    cards: List[CardInput]


def _is_valid_magic_signature(file_bytes: bytes) -> bool:
    """Verify binary header signatures for JPEG, PNG, and WebP (RIFF....WEBP)."""
    if file_bytes.startswith(b"\xff\xd8\xff") or file_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
        return True
    if file_bytes.startswith(b"RIFF") and file_bytes[8:12] == b"WEBP":
        return True
    return False


def _validate_image_bytes(file_bytes: bytes) -> None:
    """Security check: Validate magic bytes to prevent file spoofing."""
    if len(file_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is empty."
        )

    if not _is_valid_magic_signature(file_bytes):
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Unsupported image format. Only JPEG, PNG, and WebP are allowed."
        )


async def _read_and_decode_upload(file: UploadFile) -> np.ndarray:
    """Safely stream upload, decode into OpenCV matrix, and validate resolution bounds."""
    file_bytes = await file.read(MAX_UPLOAD_SIZE + 1)
    if len(file_bytes) > MAX_UPLOAD_SIZE:
        status_code = getattr(status, "HTTP_413_CONTENT_TOO_LARGE", 413)
        raise HTTPException(
            status_code=status_code,
            detail=f"Uploaded file exceeds maximum limit of {MAX_UPLOAD_SIZE // (1024 * 1024)}MB."
        )

    _validate_image_bytes(file_bytes)

    np_buffer = np.frombuffer(file_bytes, np.uint8)
    image = cv2.imdecode(np_buffer, cv2.IMREAD_COLOR)

    if image is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Failed to decode image data into valid bitmap."
        )

    try:
        validate_image_security(image)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc)
        ) from exc

    return image


@app.get("/health")
def health_check() -> Dict[str, Any]:
    """Health check endpoint reporting detector type and weights status."""
    detector_name = active_detector.__class__.__name__
    return {
        "status": "healthy",
        "service": "SET Detection Engine",
        "detector": detector_name,
        "weights_loaded": isinstance(active_detector, YoloCardDetector),
    }


@app.post("/api/v1/detect")
async def detect_sets(
    file: UploadFile = File(...),
    include_base64: bool = Query(default=True, description="Include base64 annotated image")
) -> JSONResponse:
    """Analyze uploaded photo of SET cards, detect cards, and find all SET combinations."""
    image = await _read_and_decode_upload(file)

    try:
        result = service.process_image(image, generate_visual=include_base64)
    except Exception as exc:
        status_code = getattr(status, "HTTP_422_UNPROCESSABLE_CONTENT", 422)
        raise HTTPException(
            status_code=status_code,
            detail=f"Detection processing failed: {exc}"
        ) from exc

    response_data = result.to_dict()

    if include_base64 and result.annotated_image is not None:
        success, encoded_jpg = cv2.imencode(".jpg", result.annotated_image)
        if success:
            b64_str = base64.b64encode(encoded_jpg).decode("utf-8")
            response_data["annotated_image_base64"] = f"data:image/jpeg;base64,{b64_str}"

    return JSONResponse(content=response_data)


@app.post("/api/v1/detect/image")
async def detect_sets_visual(file: UploadFile = File(...)) -> Response:
    """Analyze uploaded photo and directly return annotated JPEG image for mobile display."""
    image = await _read_and_decode_upload(file)

    result = service.process_image(image, generate_visual=True)
    if result.annotated_image is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate annotated image."
        )

    success, encoded_jpg = cv2.imencode(".jpg", result.annotated_image)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to encode annotated image to JPEG."
        )

    return Response(content=encoded_jpg.tobytes(), media_type="image/jpeg")


@app.post("/api/v1/solve")
def solve_cards(payload: SolveRequest) -> Dict[str, Any]:
    """Pure algorithmic endpoint: find all SETs from given card attributes."""
    domain_cards: List[Card] = []
    for c in payload.cards:
        domain_cards.append(
            Card.from_attributes(c.number, c.shape, c.color, c.shading)
        )

    found_sets = service.solve_cards_directly(domain_cards)

    return {
        "card_count": len(domain_cards),
        "set_count": len(found_sets),
        "sets": [s.to_dict() for s in found_sets],
    }
