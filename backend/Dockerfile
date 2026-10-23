# Stage 1: Builder stage
FROM python:3.12-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Hugging Face Spaces (Docker SDK) & Cloud Runtime stage (UID 1000, Port 7860)
FROM python:3.12-slim AS runtime

# Hugging Face Spaces requires non-root UID 1000
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -u 1000 setuser

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --chown=setuser:setuser set_engine/ ./set_engine/
COPY --chown=setuser:setuser weights/ ./weights/
COPY --chown=setuser:setuser api.py ./

USER setuser

ENV HOME=/home/setuser \
    PATH=/home/setuser/.local/bin:$PATH \
    PORT=7860

EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import os, urllib.request; port = os.getenv('PORT', '7860'); urllib.request.urlopen(f'http://127.0.0.1:{port}/health')" || exit 1

CMD ["sh", "-c", "uvicorn api:app --host 0.0.0.0 --port ${PORT:-7860}"]
