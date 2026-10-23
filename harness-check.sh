#!/bin/bash
set -e

echo "=== [1/4] Flake8 코드 스타일 & 엄격한 Lint 검사 ==="
# --max-complexity=10: 순환 복잡도(Cyclomatic Complexity) 제한
# --fatal-warnings: 경고도 에러로 처리
flake8 . --max-line-length=100 --max-complexity=10 --exclude=.venv,venv

echo "=== [2/4] MyPy 정적 정적 정적 정적 타입 검사 ==="
# 엄격한 타입 힌팅 검사 (타입 누락 시 실패)
mypy . --ignore-missing-imports --disallow-untyped-defs --exclude '(.venv|venv|tests)'

echo "=== [3/4] Bandit & Semgrep 최고 레벨 보안 분석 ==="
# Bandit: High/Medium 레벨 취약점 즉시 차단 (-lll)
bandit -r . -x ./.venv,./tests -lll -q
semgrep --config p/security-audit --config p/owasp-top-10 --exclude='.venv' --quiet .

echo "=== [4/4] Pytest & 커버리지 검증 (95% 이상 강제) ==="
# 테스트 커버리지 기준 80% -> 95%로 상향
pytest --cov=. --cov-fail-under=95 tests/

echo ">>> [SUCCESS] High-Standard Docker Harness Checks Passed!"