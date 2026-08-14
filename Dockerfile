# ==========================================
# 阶段 1: Builder (负责编译 pynini 等 C++ 依赖)
# ==========================================
FROM python:3.12-slim AS builder

WORKDIR /app

# 1. 补齐编译必需的 g++、build-essential 和 git
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 2. 克隆代码并移除 .git 历史记录以省空间
RUN git clone --depth 1 https://github.com/OpenMOSS/MOSS-TTS-Nano.git . \
    && rm -rf .git

# 3. 创建 Python 虚拟环境
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 4. 安装 Python 依赖（此时环境已有 g++，pynini 能够顺利编译）
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir onnxruntime && \
    pip install --no-cache-dir --no-deps -e .

# 5. 清理缓存文件夹
RUN find /opt/venv -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

# ==========================================
# 阶段 2: Runtime (极简运行环境，不包含 g++)
# ==========================================
FROM python:3.12-slim AS runtime

WORKDIR /app

# 仅安装运行时必要的 C 动态库（无需安装昂贵的 g++ 和编译工具）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# 从 builder 复制已编译好的包和源码
COPY --from=builder /app /app
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH" \
    GRADIO_SERVER_NAME="0.0.0.0" \
    GRADIO_SERVER_PORT=7860 \
    PYTHONUNBUFFERED=1

EXPOSE 7860

CMD ["python", "app_onnx.py", "--host", "0.0.0.0", "--port", "7860"]