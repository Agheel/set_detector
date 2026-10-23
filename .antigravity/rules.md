# Project Harness Rules

## 1. File Protection
- `harness-check.sh`, `Dockerfile.harness` 파일은 절대 수정/삭제하지 않는다.

## 2. Dynamic Context Reading
- 새 모듈 작성, 클래스 구조 변경, 기능 구현 지시를 받으면 코드를 짜기 전에 반드시 프로젝트 루트의 `ARCHITECTURE.md`를 자율적으로 읽고 지침을 준수한다.

## 3. Verification Gatekeeper
- 구현 및 수정 완료 후 반드시 아래 명령어를 실행하여 100% 통과한다:
  `docker run --rm -v "${PWD}:/app" harness-runner`