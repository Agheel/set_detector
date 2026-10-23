---
title: SET Game YOLO Detector API
emoji: 🃏
colorFrom: cyan
colorTo: indigo
sdk: docker
app_port: 7860
pinned: false
---

# SET Detector Backend (`backend/`) — Hugging Face Spaces (Docker)

FastAPI 및 컴퓨터 비전(YOLO/OpenCV), 유한체 $\mathbb{F}_3^4$ Modulo 3 고속 솔버로 구성된 백엔드 엔진입니다. **Hugging Face Spaces (Docker SDK, 2 vCPU · 16GB RAM 무료 티어)**에 바로 배포할 수 있도록 설정되어 있습니다.

---

## 1. Hugging Face Spaces 영구 무료(0원) 배포 가이드

1. [Hugging Face Spaces](https://huggingface.co/spaces) 접속 후 **Create new Space**를 클릭합니다.
2. 아래 항목을 선택하여 Space를 생성합니다:
   - **Space name:** `set-detector` (원하는 이름)
   - **Select the Space SDK:** **`Docker`** 선택 $\rightarrow$ **`Blank`** 템플릿 선택
   - **Space hardware:** **`CPU basic · 2 vCPU · 16 GB · FREE`** (기본값)
   - **Visibility:** `Public`
3. 프로젝트 루트에서 아래 명령어로 `backend/` 폴더만 Hugging Face Space에 바로 푸쉬합니다:
   ```bash
   git remote add hf https://huggingface.co/spaces/<본인_HF_아이디>/set-detector
   git subtree push --prefix backend hf main
   ```
   *(또는 Hugging Face 웹 화면의 `Files` 탭 $\rightarrow$ `Add file` $\rightarrow$ `Upload files`에 `backend/` 폴더 안의 파일들을 그대로 드래그 앤 드롭해도 자동으로 빌드됩니다.)*
4. 빌드가 완료(`Running`)되면 발급된 무료 주소 **`https://<본인_HF_아이디>-set-detector.hf.space`**를 휴대폰 앱(`02 카메라` 화면 우측 상단 `☁️` 버튼)에 입력하여 즉시 연결합니다.

---

## 2. YOLO 가중치 파일(`.pt` / `.onnx`) 추가 방법
- 학습된 가중치 파일(예: `best.pt`)을 `backend/weights/best.pt` 경로에 넣고 푸쉬하거나, Hugging Face Space 웹의 `weights/` 폴더에 업로드하면 코드 수정 없이 자동으로 `YoloCardDetector`가 활성화됩니다.
