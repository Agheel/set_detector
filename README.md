# SET Game YOLO Detection & Solver (`set_detector`)

컴퓨터 비전(YOLO) 모델을 활용하여 보드게임 **세트(SET)** 카드를 실시간으로 탐지하고, 유한 기하학($\mathbb{F}_3^4$) 알고리즘으로 유효한 3장 조합(SET)을 자동 판별 및 시각화하는 백엔드 엔진입니다.

---

## 1. 아키텍처 및 SOLID 설계 원칙

본 프로젝트는 `ARCHITECTURE.md`에 정의된 **SOLID 원칙**과 **Security-First 아키텍처**를 엄격히 준수합니다.

- **SRP (단일 책임 원칙)**
  - `set_engine/models.py`: 불변(`frozen=True`) 도메인 엔티티 (`Card`, `BoundingBox`, `DetectedCard`, `SetCombination`) 정의
  - `set_engine/solver.py`: 유한체 $\text{GF}(3)$ 기반 Modulo 3 연산 및 $\mathcal{O}(N^2)$ 보완 카드(Complement) 탐색 알고리즘 전담
  - `set_engine/detector.py`: 이미지 보안 검증 및 YOLO/Mock 카드 객체 탐지 전담
  - `set_engine/visualizer.py`: OpenCV 기반 바운딩 박스 및 유효 SET 삼각 연결선 렌더링 전담
  - `set_engine/service.py`: 탐지 $\rightarrow$ 판별 $\rightarrow$ 시각화 파이프라인 조율(Orchestration) 전담
  - `api.py`: FastAPI 기반 RESTful 엔드포인트, 파일 업로드 보안 검증 및 직렬화 전담
- **OCP & LSP (개방-폐쇄 및 리스코프 치환 원칙)**
  - `ICardDetector` 인터페이스를 통해 실전용 `YoloCardDetector`와 테스트/개발용 `MockCardDetector`를 비즈니스 로직 수정 없이 완벽히 치환 가능
- **ISP & DIP (인터페이스 분리 및 의존성 역전 원칙)**
  - `SetService`는 구체 클래스가 아닌 `ICardDetector`, `ISetSolver`, `ISetVisualizer` 추상 인터페이스에만 의존

---

## 2. 보안 방어 기작 (Security-First Mechanisms)

1. **Magic Bytes 시그니처 검증 (`api.py`)**: 확장자 위조(Spoofing) 및 악성 스크립트 업로드를 차단하기 위해 바이너리 헤더(JPEG `\xff\xd8\xff`, PNG `\x89PNG\r\n\x1a\n`, WebP `RIFF`)를 직접 검증합니다.
2. **DoS 및 Decompression Bomb 방어 (`api.py`, `set_engine/detector.py`)**:
   - 업로드 스트림 크기를 최대 **5MB**로 제한하여 메모리 고갈 공격을 차단합니다 (`HTTP 413`).
   - 디코딩된 이미지 행렬의 타입(`uint8`), 채널(`3채널 BGR`), 해상도(`32x32` ~ `4096x4096`)를 엄격히 검증합니다.
3. **경로 순회(Path Traversal) 방어 (`set_engine/detector.py`)**:
   - YOLO 가중치 로드 시 `os.path.realpath` 정규화 및 허용 확장자(`.pt`, `.onnx`) 화이트리스트 검증을 수행합니다.
4. **정적 보안 감사 준수**: 프로덕션 코드 내 `assert` 문을 배제하고 명시적 예외 처리 및 정형화된 HTTP 상태 코드를 반환합니다.

---

## 3. REST API 명세

| 메서드 | 엔드포인트 | 설명 |
| :--- | :--- | :--- |
| `GET` | `/health` | 서버 상태 및 현재 활성화된 탐지기(`YoloCardDetector` / `MockCardDetector`) 확인 |
| `POST` | `/api/v1/detect` | 카드 이미지 업로드 $\rightarrow$ 탐지된 카드 목록, 유효 SET 조합, Base64 시각화 이미지 반환 |
| `POST` | `/api/v1/detect/image` | 카드 이미지 업로드 $\rightarrow$ SET 조합이 하이라이트된 JPEG 이미지 바이너리 직접 반환 |
| `POST` | `/api/v1/solve` | 카드 속성(숫자, 모양, 색상, 음영) JSON 리스트 입력 $\rightarrow$ 유효 SET 조합 반환 |

---

## 4. 실행 및 검증 방법

### 로컬 서버 실행
```bash
pip install -r requirements.txt
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

### 하네스(Harness) 품질 및 보안 검증
```bash
flake8 . --max-line-length=100 --max-complexity=10 --exclude=.venv,venv
mypy . --ignore-missing-imports --disallow-untyped-defs --exclude '(.venv|venv|tests)'
bandit -r . -x ./.venv,./tests -lll -q
pytest --cov=. --cov-fail-under=95 tests/
```
