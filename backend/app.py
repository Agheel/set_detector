"""Hugging Face Spaces (Gradio SDK Free Tier) entry point mounting FastAPI SET Engine."""

import os
from typing import Any, Tuple
import uvicorn

from api import app, service


def gradio_predict(image_np: Any) -> Tuple[Any, Any]:
    """Process numpy image array from Gradio UI using SetService."""
    if image_np is None:
        return None, {"error": "이미지를 업로드해주세요."}
    result = service.process_image(image_np, generate_visual=True)
    return result.annotated_image, result.to_dict()


def attach_gradio_ui(fastapi_app: Any) -> Any:
    """Attach optional Gradio Blocks UI at '/ui' while preserving all FastAPI REST routes."""
    try:
        import gradio as gr  # type: ignore

        with gr.Blocks(title="Set Detector AI Engine") as demo:  # pragma: no cover
            gr.Markdown("## 🃏 SET Game YOLO Detection & Solver (FastAPI + Gradio)")
            img_in = gr.Image(type="numpy", label="SET 카드 이미지 업로드")
            img_out = gr.Image(type="numpy", label="SET 탐지 결과 시각화")
            json_out = gr.JSON(label="탐지된 카드 및 유효 SET 조합 (JSON)")
            btn = gr.Button("세트 분석 실행", variant="primary")
            btn.click(fn=gradio_predict, inputs=img_in, outputs=[img_out, json_out])

        return gr.mount_gradio_app(fastapi_app, demo, path="/ui")  # pragma: no cover
    except ImportError:
        return fastapi_app


def get_space_port() -> int:
    """Resolve port for Hugging Face Spaces (default 7860) or Cloud environment."""
    raw_port = os.getenv("GRADIO_SERVER_PORT", os.getenv("PORT", "7860"))
    try:
        return int(raw_port)
    except ValueError:
        return 7860


space_app = attach_gradio_ui(app)


def main() -> None:
    """Start Uvicorn server hosting both FastAPI endpoints and Gradio UI on port 7860."""
    port = get_space_port()
    uvicorn.run(space_app, host="0.0.0.0", port=port)  # nosec B104


if __name__ == "__main__":  # pragma: no cover
    main()
