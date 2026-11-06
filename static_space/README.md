---
title: Set Detector AI
emoji: 🃏
colorFrom: blue
colorTo: indigo
sdk: static
app_file: index.html
pinned: false
---

# 🃏 Set Detector — 100% On-Device Web AI (`Static` Space & GitHub Pages)

별도의 백엔드 서버 비용 없이 **Hugging Face 무료 `Static` Space** 또는 **GitHub Pages**에 그대로 업로드하여 스마트폰/PC 웹 브라우저에서 즉시 사용할 수 있는 **서버리스(Serverless) 온디바이스 AI 웹 애플리케이션**입니다.

## 주요 특징
1. **Figma 디자인 100% 반영**: `01 시작 안내` ~ `05B 촬영 품질 확인` 6대 화면 및 벡터 카드 렌더링 완벽 구현.
2. **브라우저 내장 YOLOv11 (`best.onnx` + ONNX Runtime Web)**: 촬영하거나 앨범에서 불러온 카드 이미지를 외부 서버 전송 없이 브라우저 내에서 직접 탐지(`82개 클래스 GDE1~RTS3` 파싱).
3. **유한기하학 $\mathbb{F}_3^4$ 고속 솔버**: 탐지된 카드들로부터 $\mathcal{O}(N^2)$ 보완 카드 알고리즘으로 모든 유효 세트(SET)를 1ms 이내에 판별.
4. **무료 배포 방법 (Hugging Face `Static` Space)**:
   - Hugging Face에서 **New Space** → SDK로 **`Static` (무료)** 선택
   - 이 `static_space/` 폴더 안의 파일들(`index.html`, `styles.css`, `app.js`, `best.onnx`, `README.md`)을 업로드하면 즉시 배포 완료!
