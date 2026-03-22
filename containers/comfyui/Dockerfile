FROM python:3.12-slim-bookworm

LABEL maintainer="julien.pierret@gmail.com"
LABEL org.opencontainers.image.title="ComfyUI"
LABEL org.opencontainers.image.description="Pinned ComfyUI image with ComfyUI-Manager and ComfyUI-Sentinel"
LABEL org.opencontainers.image.source="https://github.com/dafrenchyman/dockers_and_helm"

ARG DEBIAN_FRONTEND=noninteractive
ARG COMFYUI_REF=v0.18.0
ARG COMFYUI_MANAGER_REF=f4fa394
ARG COMFYUI_SENTINEL_REF=0d57d47

ENV APP_HOME=/opt/comfyui \
    COMFYUI_USER_DIR=/opt/comfyui/user \
    COMFYUI_TEMP_DIR=/opt/comfyui/user/temp \
    COMFYUI_PORT=8188 \
    COMFYUI_HOST=0.0.0.0 \
    COMFYUI_PATH=/opt/comfyui \
    COMFYUI_MUTABLE_CUSTOM_NODES_DIR=/opt/comfyui/custom_nodes \
    COMFYUI_BAKED_CUSTOM_NODES_DIR=/opt/comfyui/baked_custom_nodes \
    COMFYUI_SENTINEL_STATE_DIR=/opt/comfyui/state/sentinel \
    PUID=1000 \
    PGID=1000 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    SECRET_KEY=

WORKDIR /opt/comfyui

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    ffmpeg \
    git \
    gosu \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    tini \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.base.txt /tmp/requirements.base.txt
COPY requirements.extra.txt /tmp/requirements.extra.txt

RUN python -m pip install --upgrade pip setuptools wheel \
 && python -m pip install -r /tmp/requirements.base.txt

RUN git clone --branch "${COMFYUI_REF}" --depth 1 https://github.com/comfyanonymous/ComfyUI.git /opt/comfyui \
 && python -m pip install -r /opt/comfyui/requirements.txt

RUN mkdir -p /opt/comfyui/baked_custom_nodes \
 && git clone https://github.com/Comfy-Org/ComfyUI-Manager.git /opt/comfyui/baked_custom_nodes/ComfyUI-Manager \
 && cd /opt/comfyui/baked_custom_nodes/ComfyUI-Manager \
 && git checkout "${COMFYUI_MANAGER_REF}" \
 && test -f requirements.txt \
 && python -m pip install -r requirements.txt

RUN git clone https://github.com/LucipherDev/ComfyUI-Sentinel.git /opt/comfyui/baked_custom_nodes/ComfyUI-Sentinel \
 && cd /opt/comfyui/baked_custom_nodes/ComfyUI-Sentinel \
 && git checkout "${COMFYUI_SENTINEL_REF}" \
 && python -m pip install -r requirements.txt

RUN python -m pip install -r /tmp/requirements.extra.txt \
 && rm -rf /tmp/requirements.base.txt /tmp/requirements.extra.txt

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
 && mkdir -p \
    /opt/comfyui/models/checkpoints \
    /opt/comfyui/models/clip \
    /opt/comfyui/models/clip_vision \
    /opt/comfyui/models/configs \
    /opt/comfyui/models/controlnet \
    /opt/comfyui/models/diffusion_models \
    /opt/comfyui/models/embeddings \
    /opt/comfyui/models/loras \
    /opt/comfyui/models/upscale_models \
    /opt/comfyui/models/vae \
    /opt/comfyui/input \
    /opt/comfyui/output \
    /opt/comfyui/custom_nodes \
    /opt/comfyui/state/sentinel \
    /opt/comfyui/user \
    /opt/comfyui/user/temp \
 && groupadd --gid 1000 comfy \
 && useradd --uid 1000 --gid 1000 --create-home --home-dir /home/comfy --shell /usr/sbin/nologin comfy

EXPOSE 8188/tcp

VOLUME ["/opt/comfyui/models", "/opt/comfyui/input", "/opt/comfyui/output", "/opt/comfyui/custom_nodes", "/opt/comfyui/state/sentinel", "/opt/comfyui/user"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8188/', timeout=3)"

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
