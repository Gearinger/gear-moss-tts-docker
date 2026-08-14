FROM python:3.12-slim

WORKDIR /app

# 注意每行末尾的 \ 符号
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/OpenMOSS/MOSS-TTS-Nano.git .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir onnxruntime

RUN pip install -e .

EXPOSE 7860

CMD ["python", "app_onnx.py", "--host", "0.0.0.0", "--port", "7860"]