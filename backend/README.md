---
title: SET Game YOLO Detector API
emoji: 🃏
colorFrom: cyan
colorTo: indigo
sdk: gradio
app_file: app.py
pinned: false
---

# SET Detector Backend (`backend/`) — Hugging Face Spaces (Gradio 무료 모드)

FastAPI 및 컴퓨터 비전(YOLO/OpenCV), 유한체 $\mathbb{F}_3^4$ Modulo 3 고속 솔버로 구성된 백엔드 엔진입니다.
**Hugging Face Spaces의 무료 `Gradio` SDK (`CPU basic · 2 vCPU · 16GB RAM · FREE`)** 위에서 FastAPI 엔드포인트(`/health`, `/api/v1/detect`, `/api/v1/detect/image`, `/api/v1/solve`)와 웹 테스트 UI(`/ui`)가 동시에 구동되도록 설계되었습니다.

---

## 1. Hugging Face Spaces 영구 무료(0원) 배포 방법 (`Gradio` SDK 선택)

1. [Hugging Face Spaces](https://huggingface.co/spaces) 접속 후 **Create new Space**를 클릭합니다.
2. 아래 항목을 선택하여 Space를 생성합니다:
   - **Space name:** `set-detector` (원하는 이름)
   - **Select the Space SDK:** 무료인 **`Gradio`** 선택 (`Blank` 또는 기본 템플릿)
   - **Space hardware:** **`CPU basic · 2 vCPU · 16 GB · FREE`** (무료)
   - **Visibility:** `Public`
3. 생성된 Space에 `backend/` 폴더 내부 파일들(`app.py`, `api.py`, `requirements.txt`, `README.md`, `set_engine/`, `weights/`)을 업로드하거나 아래 Git 명령어로 푸쉬합니다:
   ```bash
   git remote add hf https://huggingface.co/spaces/<본인_HF_아이디>/set-detector
   git subtree push --prefix backend hf main
   ```
   *(웹 화면에서 올리실 경우: Space 상단 `Files` 탭 $\rightarrow$ `Add file` $\rightarrow$ `Upload files` 클릭 후 `backend/` 폴더 안의 파일들을 드래그 앤 드롭하고 `Commit changes`를 누르면 끝납니다.)*
4. 상단 상태가 **`Running`**으로 바뀌면 **`https://<본인_HF_아이디>-set-detector.hf.space`** 주소를 복사하여 휴대폰 앱(`02 카메라` 화면 우측 상단 `☁️` 버튼)에 입력합니다.
   - 모바일 API 엔드포인트: `https://<본인_HF_아이디>-set-detector.hf.space/api/v1/detect`
   - 헬스체크 엔드포인트: `https://<본인_HF_아이디>-set-detector.hf.space/health`
   - 웹 브라우저 테스트 UI: `https://<본인_HF_아이디>-set-detector.hf.space/ui`

---

## 2. YOLO 가중치 파일(`.pt` / `.onnx`) 추가 방법
- 학습된 가중치 파일(예: `best.pt`)을 `backend/weights/best.pt` 경로에 넣으면 코드 수정 없이 자동으로 `YoloCardDetector`가 활성화됩니다.
