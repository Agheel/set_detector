# SET Detector Backend (`backend/`)

FastAPI 및 컴퓨터 비전(YOLO/OpenCV), 유한체 $\mathbb{F}_3^4$ Modulo 3 고속 솔버로 구성된 백엔드 엔진 디렉터리입니다.

## 디렉터리 구조
- `api.py`: FastAPI 엔드포인트 (`/health`, `/api/v1/detect`, `/api/v1/detect/image`, `/api/v1/solve`) 및 보안 검증(Magic Bytes, 5MB 업로드 제한, 해상도 방어)
- `set_engine/`: SOLID 원칙 기반 코어 패키지
  - `models.py`: 불변 도메인 모델 (`Card`, `BoundingBox`, `DetectedCard`, `SetCombination`)
  - `detector.py`: `ICardDetector`, `YoloCardDetector`, `MockCardDetector`, `discover_weights_path`
  - `solver.py`: `ISetSolver`, `FastSetSolver` ($\mathcal{O}(N^2)$ 보완 카드 탐색)
  - `visualizer.py`: `ISetVisualizer`, `SetVisualizer` (OpenCV 어노테이션 렌더링)
  - `service.py`: `SetService` 파이프라인 조율
- `weights/`: YOLO 가중치 파일(`.pt`, `.onnx`) 투입 폴더 (투입 시 자동 인식)
- `Dockerfile`: Python 3.12 멀티스테이지 보안 컨테이너 빌드 설정
- `requirements.txt`: 백엔드 의존성 목록

## 실행 방법
```bash
cd backend
pip install -r requirements.txt
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```
