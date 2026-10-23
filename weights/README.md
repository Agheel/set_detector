# YOLO Weights Directory (`weights/`)

이 디렉토리에 학습된 YOLO 가중치 파일(`.pt` 또는 `.onnx`)을 넣으면, 코드 수정 없이 서버 시작 시 자동으로 `YoloCardDetector`가 활성화됩니다.

## 자동 탐색 우선순위
1. 환경 변수 `SET_YOLO_WEIGHTS`에 지정된 파일 경로
2. `weights/best.pt`
3. `weights/set_yolo.pt`
4. `weights/model.pt`
5. `weights/best.onnx`
6. `weights/model.onnx`
7. `weights/` 폴더 내 임의의 `.pt` 또는 `.onnx` 파일

> 가중치 파일이 없을 경우 자동으로 `MockCardDetector`로 폴백(Fallback)되어 API 및 프론트엔드/모바일 연동 테스트를 즉시 수행할 수 있습니다.
