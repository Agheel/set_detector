# Stage 1: Builder stage
FROM python:3.12-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Minimal & Hardened Cloud Runtime stage (Cloud Run / Railway / Render compatible)
FROM python:3.12-slim AS runtime

WORKDIR /app

# Install minimal runtime shared libraries required by OpenCV headless
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r setuser && useradd -r -g setuser setuser

COPY --from=builder /install /usr/local
COPY set_engine/ ./set_engine/
COPY weights/ ./weights/
COPY api.py ./

RUN chown -R setuser:setuser /app
USER setuser

ENV PORT=8000
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import os, urllib.request; port = os.getenv('PORT', '8000'); urllib.request.urlopen(f'http://127.0.0.1:{port}/health')" || exit 1

CMD ["sh", "-c", "uvicorn api:app --host 0.0.0.0 --port ${PORT:-8000}"]
