# SET Game YOLO Detection & Solver (`set_detector`)

컴퓨터 비전(YOLO) 모델과 유한 기하학($\mathbb{F}_3^4$) 고속 솔버를 결합한 **백엔드(`backend/`)** 및 Figma 디자인 시스템 기반 **Flutter 프론트엔드(`frontend/`)** 모노레포 프로젝트입니다.

---

## 1. 프로젝트 디렉터리 구조 (`backend` / `frontend` 분리)

```text
set_detector/
├── backend/                  # FastAPI + YOLO 비전 추론 + GF(3)^4 솔버 백엔드
│   ├── api.py                # REST API 엔드포인트 및 Magic Bytes/DoS 방어
│   ├── set_engine/           # SOLID 아키텍처 코어 엔진 (models, detector, solver, visualizer, service)
│   ├── weights/              # YOLO 가중치(.pt, .onnx) 자동 로드 디렉터리
│   ├── Dockerfile            # Python 3.12 멀티스테이지 컨테이너 빌드
│   └── requirements.txt      # 백엔드 패키지 의존성
├── frontend/                 # Figma 'Set' 디자인 기반 Flutter 모바일 프론트엔드
│   ├── lib/
│   │   ├── main.dart         # 6대 화면 네비게이션 플로우 조율
│   │   ├── models/           # 불변 카드/탐지 결과 도메인 모델
│   │   ├── services/         # 백엔드 API 클라이언트 및 오프라인 GF(3)^4 솔버
│   │   ├── theme/            # Figma 색상 토큰 및 다크 테마
│   │   ├── widgets/          # 벡터 카드 심볼 및 네온 삼각 연결 CustomPainter
│   │   └── screens/          # 01 시작 안내 ~ 05B 촬영 품질 6대 화면
│   └── pubspec.yaml          # Flutter 프로젝트 설정
├── tests/                    # 하네스 단위/통합 테스트 스위트 (커버리지 99%+)
├── ARCHITECTURE.md           # 시스템 요구사항, 기술 스택 및 아키텍처 명세서
├── docker-compose.yml        # 백엔드 컨테이너 오케스트레이션
├── Dockerfile.harness        # 품질/보안 검증 하네스 컨테이너
└── harness-check.sh          # Flake8, MyPy, Bandit, Semgrep, Pytest 자동 검증 스크립트
```

---

## 2. 실행 방법

### 백엔드 (`backend/`) 실행
```bash
cd backend
pip install -r requirements.txt
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```
- 학습된 YOLO 가중치 파일(`.pt` 또는 `.onnx`)은 `backend/weights/` 폴더(예: `backend/weights/best.pt`)에 넣으면 코드 수정 없이 즉시 `YoloCardDetector`로 동작합니다.

### 프론트엔드 (`frontend/`) 실행
```bash
cd frontend
flutter pub get
flutter run
```

### 하네스(Harness) 품질 및 보안 검증
```bash
flake8 . --max-line-length=100 --max-complexity=10 --exclude=.venv,venv
mypy . --ignore-missing-imports --disallow-untyped-defs --exclude '(.venv|venv|tests)'
bandit -r . -x ./.venv,./tests -lll -q
pytest --cov=. --cov-fail-under=95 tests/
```
