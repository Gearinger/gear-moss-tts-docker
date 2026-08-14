# gear-moss-tts-docker

轻量级、跨架构（`amd64` / `arm64`）的 **MOSS-TTS-Nano** (ONNX 引擎) Docker 镜像，内置 Gradio Web UI，开箱即用。

[![Build and Push Docker Image](https://github.com/Gearinger/gear-moss-tts-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/Gearinger/gear-moss-tts-docker/actions/workflows/docker-build.yml)
[![GHCR Registry](https://img.shields.io/badge/GHCR-gearinger%2Fgear--moss--tts--docker-blue?logo=github)](https://github.com/Gearinger/gear-moss-tts-docker/pkgs/container/gear-moss-tts-docker)
[![Architecture](https://img.shields.io/badge/Architecture-amd64%20%7C%20arm64-brightgreen)](#)

---

## ✨ 特性

- 🚀 **原生多架构支持**：基于 GitHub Actions CI 构建，同时提供 `linux/amd64` (x86_64) 与 `linux/arm64` (Apple Silicon / ARM64 云服务器) 镜像。
- ⚡ **ONNX Runtime 加速**：基于 `app_onnx.py` 驱动，相比完整 PyTorch 降低了 CPU 推理延迟与内存占用。
- 📦 **持久化模型缓存**：支持挂载 `/root/.cache` 目录，防止容器重启时重复下载语音模型。
- 🛡️ **灵活部署**：开箱支持 Docker CLI、Docker Compose、Podman 以及 Podman Pod 部署。

---

## 🚀 快速开始

### 1. 使用 Docker CLI 运行

```bash
docker run -d \
  --name gear-moss-tts \
  --restart unless-stopped \
  -p 7860:7860 \
  -v moss_model_cache:/root/.cache \
  ghcr.io/gearinger/gear-moss-tts-docker:latest
```

服务启动后，在浏览器中访问：http://<服务器IP>:78602. 

### 2. 使用 Docker Compose / Podman Compose

创建 compose.yml 

```YAML
version: '3.8'

services:
  gear-moss-tts:
    image: ghcr.io/gearinger/gear-moss-tts-docker:latest
    container_name: gear-moss-tts
    restart: unless-stopped
    ports:
      - "7860:7860"
    environment:
      - GRADIO_SERVER_NAME=0.0.0.0
      - GRADIO_SERVER_PORT=7860
      - PYTHONUNBUFFERED=1
    volumes:
      - moss_model_cache:/root/.cache

volumes:
  moss_model_cache:
    driver: local
```

启动命令：Bashdocker compose up -d 或 podman-compose up -d

## 🛠️ 本地构建与调试
如需自行修改源码或离线编译镜像：

```Bash
# 1. 克隆本仓库
git clone [https://github.com/Gearinger/gear-moss-tts-docker.git](https://github.com/Gearinger/gear-moss-tts-docker.git)
cd gear-moss-tts-docker

# 2. 构建本地镜像
docker build -t gear-moss-tts:local .

# 3. 运行本地容器
docker run -d -p 7860:7860 gear-moss-tts:local
```

## 📄 致谢与声明
核心 TTS 逻辑与权重来源于 OpenMOSS / MOSS-TTS-Nano。

本仓库仅提供容器化构建脚本与多架构 CI/CD 发布流程。