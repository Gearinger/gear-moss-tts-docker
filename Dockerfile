# syntax=docker/dockerfile:1
FROM python:3.12-slim AS builder

WORKDIR /app

# 1. 挂载 apt 缓存
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    g++ \
    libfst-dev

RUN git clone --depth 1 https://github.com/OpenMOSS/MOSS-TTS-Nano.git . \
    && rm -rf .git

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 2. 挂载 pip 缓存（即便层失效，下载过的 whl 也不用重拉）
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install torch --index-url https://download.pytorch.org/whl/cpu && \
    pip install -r requirements.txt && \
    pip install onnxruntime && \
    pip install --no-deps -e .

RUN find /opt/venv -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

FROM python:3.12-slim AS runtime

WORKDIR /app

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    libfst-dev

COPY --from=builder /app /app
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH" \
    GRADIO_SERVER_NAME="0.0.0.0" \
    GRADIO_SERVER_PORT=7860 \
    PYTHONUNBUFFERED=1

EXPOSE 7860

CMD ["python", "app_onnx.py", "--host", "0.0.0.0", "--port", "7860"]