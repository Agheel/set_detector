# SET Game YOLO Detection & Solver (`set_detector`) Architecture Specification

## 1. 프로젝트 개요 (Project Overview)
- **프로젝트 명:** `set_detector` (SET Game YOLO Detection & Solver Backend Engine)
- **목적:** 보드게임 **세트(SET)** 카드를 실시간 컴퓨터 비전(YOLO) 모델을 통해 객체 탐지하고, 유한체 $\mathbb{F}_3^4$ 상의 기하학적 수식을 적용하여 유효한 3장 세트(SET) 조합을 $\mathcal{O}(N^2)$ 속도로 판별하며, 그 결과를 시각화하여 모바일 및 웹 클라이언트에 RESTful API로 제공하는 고신뢰성 백엔드 시스템.
- **핵심 가치:**
  1. **정확도(Accuracy):** 4가지 카드 속성(개수, 모양, 색상, 음영)의 도메인 엔티티 변환 및 완벽한 조합 판별.
  2. **보안성(Security-First):** Magic Bytes 헤더 검증, 5MB 페이로드 제한, DoS/Decompression Bomb 방어, Path Traversal 차단.
  3. **확장성(Extensibility):** SOLID 원칙에 입각한 인터페이스 추상화로 YOLOv8, YOLOv11, ONNX Runtime 등 모델의 자유로운 교체 보장.
  4. **모바일 친화성(Mobile-Ready):** 메타데이터 JSON, 바이너리 JPEG 직접 스트리밍, 온디바이스 탐지기를 위한 경량 솔버 엔드포인트 지원.

---

## 2. 요구사항 명세서 (Requirements Specification)

### 2.1 기능적 요구사항 (Functional Requirements - FR)
| ID | 요구사항 명칭 | 세부 내용 | 중요도 |
| :--- | :--- | :--- | :--- |
| **FR-01** | **카드 이미지 객체 탐지** | 업로드된 카드 이미지에서 카드 객체를 검출하고, Bounding Box 좌표(`xmin, ymin, xmax, ymax`) 및 신뢰도(`confidence`)를 산출해야 한다. | 필수 (High) |
| **FR-02** | **4대 카드 속성 모델링** | 각 탐지된 카드로부터 4가지 속성(개수: 1~3, 모양: 1~3, 색상: 1~3, 음영: 1~3)을 추출하여 도메인 모델(`Card`)로 변환해야 한다. | 필수 (High) |
| **FR-03** | **수학적 고속 SET 판별** | 탐지된 $N$장의 카드 중 유효한 3장 세트 조합을 $\mathbb{F}_3^4$ Modulo 3 수식 및 $\mathcal{O}(N^2)$ 보완 카드(Complement) 해시 알고리즘으로 전수 판별해야 한다. | 필수 (High) |
| **FR-04** | **세트 시각화 및 어노테이션** | 원본 이미지 상에 탐지된 카드의 바운딩 박스를 렌더링하고, 유효 세트로 묶인 3장 카드 간의 삼각 연결선 및 고유 색상 하이라이트를 주석 처리해야 한다. | 필수 (High) |
| **FR-05** | **모바일 연동 RESTful API** | 모바일/웹 클라이언트가 통신할 수 있는 4대 표준 엔드포인트(`GET /health`, `POST /api/v1/detect`, `POST /api/v1/detect/image`, `POST /api/v1/solve`)를 제공해야 한다. | 필수 (High) |
| **FR-06** | **Mock / 실전 모델 무중단 치환** | 환경 변수(`SET_YOLO_WEIGHTS`)의 유무 및 파일 무결성에 따라 `YoloCardDetector`와 `MockCardDetector` 간 자동 폴백 및 무중단 치환이 가능해야 한다. | 중간 (Medium) |

### 2.2 비기능적 요구사항 (Non-Functional Requirements - NFR)
| ID | 구분 | 요구사항 명세 | 검증 기준 |
| :--- | :--- | :--- | :--- |
| **NFR-01** | **보안성 (Security)** | - Magic Bytes 바이너리 시그니처 검증을 통해 파일 위조 및 웹쉘 업로드 원천 차단.<br>- 파일 업로드 5MB 제한 및 Decompression Bomb 방어 (해상도 범위 검증).<br>- 모델 경로 탐색(Path Traversal) 공격 완전 차단.<br>- 프로덕션 코드 내 `assert`문 배제 및 Bandit/Semgrep 보안 감사 무결점 준수. | Bandit (-lll) 0건<br>Semgrep OWASP 0건 |
| **NFR-02** | **성능 (Performance)** | - SET 판별 알고리즘 연산 시간: 12~15장 기준 5ms 이내 달성 ($\mathcal{O}(N^2)$ 해시맵 최적화).<br>- 단일 이미지 파이프라인 지연시간 최소화. | 단위 테스트 벤치마크 통과 |
| **NFR-03** | **아키텍처 (Maintainability)** | - SOLID 5대 원칙을 철저히 준수하여 계층 간 결합도를 낮추고 모듈화 달성.<br>- 엄격한 정적 타입 힌팅(MyPy Strict) 적용. | MyPy `--disallow-untyped-defs` 통과 |
| **NFR-04** | **품질 보증 (Reliability)** | - 단위 테스트 및 통합 테스트 코드 커버리지 95% 이상 강제.<br>- Flake8 코드 스타일 및 Cyclomatic Complexity $\le 10$ 유지. | Pytest 커버리지 $\ge 95\%$ 달성 |
| **NFR-05** | **호환성 (Compatibility)** | - 모바일 클라이언트 통신을 위한 CORS 전면 지원.<br>- Base64 문자열 인코딩 및 바이너리 스트리밍(`image/jpeg`) 다중 인터페이스 제공. | iOS/Android 모바일 호환 |

---

## 3. 기능 명세서 (Functional Specification)

### 3.1 이미지 수신 및 보안 검증 기능 (F-01: Secure Image Ingestion)
- **입력:** 멀티파트 폼 데이터(`UploadFile`) 형태의 이미지 바이트 스트림.
- **처리 절차:**
  1. **바이트 크기 검사:** 스트림 길이가 `5 * 1024 * 1024` 바이트(5MB)를 초과하는지 검사. 초과 시 `HTTP 413 Payload Too Large` 반환.
  2. **Magic Bytes 시그니처 검사:**
     - JPEG: `\xff\xd8\xff`
     - PNG: `\x89PNG\r\n\x1a\n`
     - WebP: `RIFF` (offset 0) 및 `WEBP` (offset 8)
     - 불일치 시 `HTTP 415 Unsupported Media Type` 예외 발생.
  3. **비트맵 디코딩 및 행렬 검증:**
     - OpenCV `cv2.imdecode`로 바이트 스트림을 BGR 3채널 `uint8` 넘파이 행렬로 디코딩.
     - 이미지 해상도가 $32 \times 32$ 이상, $4096 \times 4096$ 이하인지 검증. 범위를 벗어날 경우 `HTTP 400 Bad Request` 반환 (Decompression Bomb 방어).

### 3.2 비전 기반 카드 객체 탐지 기능 (F-02: Vision Inference & Detection)
- **추상 인터페이스:** `ICardDetector`
- **구체 구현체:**
  1. `YoloCardDetector`:
     - Ultralytics YOLO 추론 엔진을 구동하여 카드 바운딩 박스 검출.
     - 경로 정규화(`os.path.realpath`) 및 확장자 화이트리스트(`.pt`, `.onnx`) 검증 후 가중치 로드 (Path Traversal 방어).
     - 클래스 라벨(81가지 조합 문자열, 예: `2_oval_red_solid`)을 파싱하여 `Card` 객체 생성.
  2. `MockCardDetector`:
     - YOLO 라이브러리 부재 환경 및 단위 테스트를 위한 독립형 모의 탐지기.
     - 이미지 격자(Grid) 배치 기준 사전 정의된 유효한 6~12장의 카드를 자동 생성.
- **출력:** `List[DetectedCard]` (바운딩 박스 좌표, 정규화된 도메인 `Card` 모델, 신뢰도 스코어).

### 3.3 수학적 SET 판별 및 보완 카드 탐색 엔진 (F-03: Mathematical SET Solver)
- **알고리즘 원리:** 유한체 $\mathbb{F}_3^4 \cong (\mathbb{Z}/3\mathbb{Z})^4$ 벡터 공간 모델.
- **카드 벡터 표현:**
  각 카드 $C = (a_1, a_2, a_3, a_4) \in \{1, 2, 3\}^4$ (1: 개수, 2: 모양, 3: 색상, 4: 음영).
- **세트 성립 필요충분조건:**
  세 카드 $C_i, C_j, C_k$가 유효한 세트일 조건:
  $$\forall d \in \{1, 2, 3, 4\}, \quad (C_{i, d} + C_{j, d} + C_{k, d}) \equiv 0 \pmod 3$$
- **$\mathcal{O}(N^2)$ 보완 카드(Complement) 고속 탐색 알고리즘:**
  1. 모든 카드 목록을 해시맵 `card_to_indices: Dict[Card, List[int]]`에 인덱싱 ($\mathcal{O}(N)$).
  2. 임의의 두 카드 쌍 $(C_i, C_j)$ ($i < j$) 선택 ($\mathcal{O}(N^2)$).
  3. 세트가 되기 위해 필요한 유일한 제3의 보완 카드 $C_{\text{comp}}$ 계산:
     $$C_{\text{comp}, d} = ((6 - (C_{i, d} + C_{j, d})) \bmod 3) \quad \text{(0이면 3으로 보정)}$$
  4. 해시맵에서 $C_{\text{comp}}$의 인덱스 $k$ ($k > j$)를 $\mathcal{O}(1)$로 조회하여 중복 없는 유효 세트 조합 확정.
- **출력:** `List[SetCombination]` (세트 카드 인덱스 튜플 `(i, j, k)` 및 구성 카드 객체).

### 3.4 비전 시각화 및 어노테이션 렌더링 엔진 (F-04: Visual Annotation & Rendering)
- **인터페이스:** `ISetVisualizer` (`SetVisualizer`)
- **렌더링 파이프라인:**
  1. **개별 카드 바운딩 박스 렌더링:**
     - 탐지된 모든 카드 테두리에 라운드 사각 박스 및 속성/신뢰도 텍스트 오버레이.
  2. **유효 SET 하이라이트 렌더링:**
     - 최대 8종의 고대비 색상 팔레트 순환 배정.
     - 세트를 구성하는 3개 카드의 중심점(Centroid) 계산:
       $$x_c = \frac{x_{\min} + x_{\max}}{2}, \quad y_c = \frac{y_{\min} + y_{\max}}{2}$$
     - 3개 중심점을 연결하는 삼각형 폴리라인(Polyline) 및 카드 간의 반투명 채우기 렌더링.
  3. **인코딩 변환:**
     - 가공된 이미지 행렬을 JPEG 버퍼로 압축 (`cv2.imencode`).
     - Base64 문자열 또는 바이너리 바이트 스트림 변환 지원.

### 3.5 서비스 파이프라인 조율 기능 (F-05: Orchestration Service)
- **클래스:** `SetService`
- **단일 파이프라인 조율 (`process_image`):**
  $$\text{Image Bytes} \xrightarrow{\text{Detector}} \text{Detected Cards} \xrightarrow{\text{Solver}} \text{SET Combinations} \xrightarrow{\text{Visualizer}} \text{Annotated Image} \xrightarrow{} \text{SetDetectionResult}$$
- **예외 상황 처리:**
  - 탐지된 카드가 3장 미만이거나 세트가 0개인 경우 에러 없이 빈 세트 목록과 바운딩 박스만 렌더링된 결과를 안전하게 반환.

### 3.6 모바일 클라이언트 REST API 인터페이스 (F-06: Mobile-Ready REST API)
- **FastAPI 프레임워크 기반 비동기 엔드포인트:**
  1. `GET /health`:
     - 탐지기 상태 (`status: "healthy"`), 가중치 로드 여부, 검출기 유형(`YoloCardDetector` / `MockCardDetector`) 반환.
  2. `POST /api/v1/detect`:
     - 파일 업로드 $\rightarrow$ 전체 파이프라인 수행 $\rightarrow$ 카드 목록, 세트 인덱스, Base64 시각화 이미지를 포함한 JSON 반환.
  3. `POST /api/v1/detect/image`:
     - 파일 업로드 $\rightarrow$ 주석 이미지가 포함된 `image/jpeg` 바이너리 직접 스트리밍 응답 (모바일 `UIImageView` 즉시 렌더링 최적화).
  4. `POST /api/v1/solve`:
     - 순수 카드 속성 JSON 배열 수신 $\rightarrow$ 비전 추론 없이 $\mathcal{O}(N^2)$ 솔버만 단독 수행 후 세트 조합 반환 (오프라인/온디바이스 모바일 지원).

---

## 4. 권장 기술 스택 및 아키텍처 토폴로지 (Recommended Tech Stack & Topology)

### 4.1 백엔드 및 비전/AI 코어 (Backend & Core AI)
| 영역 | 기술 스택 | 선정 및 보안/아키텍처 관점의 이유 | 비판적 검토 및 방어 기작 |
| :--- | :--- | :--- | :--- |
| **언어 & 런타임** | **Python 3.12** | 컴퓨터 비전/AI 생태계(OpenCV, PyTorch) 표준 및 최신 CPython 성능 향상, 엄격한 타입 힌팅 지원. | GIL(Global Interpreter Lock) 병목 $\rightarrow$ I/O 비동기화 및 C++ 바인딩 라이브러리로 극복. |
| **API 프레임워크** | **FastAPI + Uvicorn** | 비동기 non-blocking I/O(ASGI), Pydantic v2 기반 엄격한 페이로드 검증(DDoS/위조 방지), OpenAPI 자동 문서화. | Flask 대비 높은 자유도 $\rightarrow$ 미들웨어/예외 핸들러 명시적 설정 강제. |
| **비전 & 탐지** | **OpenCV + YOLOv8 / YOLOv11** | 실시간 객체 탐지 성능 우수, `ICardDetector` 인터페이스 추상화를 통해 ONNX Runtime 경량 추론기로 즉시 교체 가능. | 가중치 파일 로드 시 경로 순회 위험 $\rightarrow$ `realpath` 정규화 및 확장자 화이트리스트 적용. |
| **수학/솔버** | **순수 Python + Modulo 3** | 외장 라이브러리 의존성 없이 유한체 $\mathbb{F}_3^4$ 수식 기반 $\mathcal{O}(N^2)$ 해시맵 탐색으로 5ms 이내 판별. | 외부 수학 패키지 오버헤드가 없어 가장 가볍고 높은 이식성 제공. |
| **정적 분석 & 보안** | **MyPy, Bandit, Semgrep, Flake8** | MyPy Strict 타입 강제, Bandit(-lll) 보안 감사, Semgrep OWASP Top 10 취약점 사전 차단. | 코드 작성 규격이 엄격하므로 CI/CD 하네스 자동화 도구로 지속 보증. |
| **테스트 & 품질** | **Pytest + pytest-cov** | 테스트 커버리지 95% 이상 강제, 엔드포인트/알고리즘/비전 검출기 단위 및 통합 테스트 자동화. | 하네스 스크립트 실행으로 100% 통과 유지. |

### 4.2 클라이언트 계층 (Multi-Platform Client Tier)
- **1순위 권장 (모바일 앱): Flutter (Dart)**
  - **선정 이유:** 단일 코드베이스로 iOS/Android 동시 지원, 고성능 하드웨어 카메라 제어 및 60~120fps 실시간 캔버스(`CustomPainter`) 세트 하이라이트 오버레이 렌더링, 향후 TFLite/ONNX 온디바이스 탐지기 이식 용이성.
  - **주요 역할:** 실시간 카메라 뷰파인더 제공, 이미지 촬영 및 `/api/v1/detect` 전송, 주석 이미지 렌더링 또는 오버레이 폴리곤 직접 그리기.
- **2순위 대안 (반응형 웹): Next.js / React (TypeScript) + Tailwind CSS**
  - **선정 이유:** 별도 앱 설치 없이 브라우저 URL 접근만으로 체험 가능, WebRTC `navigator.mediaDevices.getUserMedia`를 활용한 실시간 카메라 캡처 및 직관적 반응형 UI 제공.

### 4.3 시스템 배포 및 인프라 (Deployment & Infrastructure)
- **컨테이너화:** Docker & Docker Compose 기반 멀티스테이지 빌드 (최소 런타임 이미지 용량 및 보안 표면 최소화).
- **자동화 하네스 (CI/CD):** `harness-check.sh` 및 `Dockerfile.harness`를 통한 Lint, Type Check, Security Audit, Test Coverage 4단계 파이프라인 무결점 통과 강제.

---

## 5. SOLID 아키텍처 설계 원칙 (SOLID Principles)
- **SRP (단일 책임 원칙):**
  - `set_engine.models`: 도메인 데이터 모델 및 불변 속성 표현.
  - `set_engine.solver`: 순수 수학적 알고리즘을 통한 Modulo 3 세트 판별 및 $\mathcal{O}(N^2)$ 보완 카드 탐색 전담.
  - `set_engine.detector`: 컴퓨터 비전 추론 및 바운딩 박스/클래스 추출 전담.
  - `set_engine.visualizer`: OpenCV 기반의 바운딩 박스 및 세트 연결 시각화 전담.
  - `set_engine.service`: 파이프라인 조율(Orchestration) 전담.
  - `api`: FastAPI 기반의 HTTP 요청/응답 직렬화 및 엔드포인트 라우팅 전담.
- **OCP (개방-폐쇄 원칙):**
  - `ICardDetector` 추상 인터페이스를 통해 향후 YOLOv8, YOLOv11, ONNX Runtime, 또는 모바일 온디바이스 탐지기 등으로 교체 시 핵심 비즈니스 로직(솔버, 서비스) 수정 없이 확장 가능.
- **LSP (리스코프 치환 원칙):**
  - 실전용 `YoloCardDetector`와 개발/테스트용 `MockCardDetector`는 모두 동일한 `ICardDetector` 계약을 완벽히 이행하여 상호 치환 가능.
- **ISP (인터페이스 분리 원칙):**
  - 탐지(`ICardDetector`), 판별(`ISetSolver`), 시각화(`ISetVisualizer`) 인터페이스를 철저히 분리하여 클라이언트가 필요치 않은 메서드에 의존하지 않음.
- **DIP (의존성 역전 원칙):**
  - 상위 서비스 계층(`SetService`)은 구체 구현체가 아닌 추상 인터페이스(`ICardDetector`, `ISetSolver`, `ISetVisualizer`)에 의존.

---

## 6. 보안 우선 방어 기작 (Security-First Architecture)
1. **Magic Bytes 검증 및 파일 위조 방지:**
   - 단순 파일 확장자 신뢰를 배제하고 바이너리 헤더의 매직 바이트(JPEG: `\xff\xd8\xff`, PNG: `\x89PNG`, WebP: `RIFF`)를 검증하여 파일 스푸핑 및 웹쉘 업로드 방어.
2. **Decompression Bomb 및 DoS 방어:**
   - 업로드 파일 크기를 5MB로 제한(`MAX_UPLOAD_SIZE = 5 * 1024 * 1024`)하여 메모리 고갈 방지.
   - 비트맵 디코딩 후 해상도 범위(32x32 ~ 4096x4096) 및 3채널(`uint8`) 검증을 거쳐 비정상적인 메모리 할당 차단.
3. **가중치 파일 경로 순회(Path Traversal) 방어:**
   - 모델 가중치 로드 시 `os.path.realpath` 정규화 및 허용된 확장자(`.pt`, `.onnx`) 검증을 통해 시스템 임의 파일 접근 차단.
4. **Bandit / Semgrep 보안 감사 준수:**
   - 릴리스 코드 내 `assert`문 배제 (Bandit S101 회피 및 런타임 최적화 플래그 영향 배제).
   - 모든 예외는 정형화된 HTTP 상태 코드(400, 413, 415, 422)로 격리 반환.

---

## 7. 품질 보증 및 하네스 검증 (QA & Harness Specification)
본 프로젝트는 [harness-check.sh](file:///c:/Users/duwns/orca/set_detector/harness-check.sh) 및 [Dockerfile.harness](file:///c:/Users/duwns/orca/set_detector/Dockerfile.harness)를 통해 4단계 품질 검증을 강제합니다:
1. **Flake8 Linter:** `--max-line-length=100 --max-complexity=10 --fatal-warnings`
2. **MyPy Type Checker:** `--ignore-missing-imports --disallow-untyped-defs` (Strict Typing)
3. **Bandit & Semgrep:** 최고 레벨 정적 보안 분석 취약점 0건 강제 (`-lll -q`)
4. **Pytest & Coverage:** 단위/통합 테스트 커버리지 **95% 이상 강제** (`--cov-fail-under=95`)
