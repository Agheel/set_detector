# Set Detector Mobile (`mobile/`) — Flutter Client

Figma 디자인 프로젝트 **`Set` (`node-id=0-1`)**의 6개 전체 화면과 재사용 컴포넌트 시스템을 100% 반영한 Flutter 모바일 애플리케이션입니다.

## 구현된 Figma 화면 목록
1. **`01  시작 안내`** (`lib/screens/onboarding_screen.dart`): 브랜드 헤더, 3장 카드 네온 삼각 연결 일러스트(`VISION / FOUR ATTRIBUTES`, `SET VERIFIED ✓`), 개인정보 즉시 폐기 안내 배지, 시작 버튼.
2. **`02  카메라 · 자동 촬영`** (`lib/screens/camera_viewfinder_screen.dart`): 자동/수동 토글 스위치, 실시간 인식 인디케이터, 3×4 12장 카드 위치 가이드, `12 / 12 CARDS · 기기 내 분석`, 80pt 셔터, 앨범 가져오기, 오프라인 수동 속성 입력 시트.
3. **`03  탐지 결과 · 3 SETs`** (`lib/screens/detection_result_screen.dart`): `✨ 3개의 SET 발견!` 칩, `01..12` 카드 번호 배지, `CustomPainter` 기반 3색(`#06B6D4`, `#F43F5E`, `#F59E0B`) 네온 삼각형 오버레이, `SET 01 / 02 / 03` 레전드 카드.
4. **`04  세트 상세 · 카드 집중`** (`lib/screens/set_detail_screen.dart`): 비활성 카드 디밍(`rgba(15,23,42,0.72)`), 선택된 세트 단독 하이라이트, 드래그 바텀시트, 4대 속성 일치/다름 조건 칩(`모양 일치`, `색상 다름`, `개수 다름`, `채움 일치`), **`2장만 힌트 보기`** 스위치 및 스와이프 페이지네이션.
5. **`05  예외 A · 세트 없음`** (`lib/screens/empty_set_screen.dart`): `0 SET` 상태 표시, `현재 세트가 없습니다. 카드 3장을 더 놓으세요.` 토스트 배너 및 재촬영 액션.
6. **`05B  예외 B · 촬영 품질`** (`lib/screens/quality_warning_screen.dart`): `흔들림 감지`(`#F43F5E`), `빛이 부족해요`(`#F59E0B`) 플래그 칩, 초점 경고 레티클 및 `화면이 흐리고 어두워요` 안내 툴팁.
