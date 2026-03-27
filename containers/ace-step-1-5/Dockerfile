FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

LABEL maintainer="julien.pierret@gmail.com"
LABEL org.opencontainers.image.title="ACE-Step 1.5"
LABEL org.opencontainers.image.description="Pinned ACE-Step 1.5 image with CUDA-oriented runtime packaging"
LABEL org.opencontainers.image.source="https://github.com/dafrenchyman/dockers_and_helm"

ARG DEBIAN_FRONTEND=noninteractive
ARG ACE_STEP_REF=eddb621

ENV APP_HOME=/opt/ace-step/app \
    DATA_ROOT=/opt/ace-step/data \
    MODELS_DIR=/opt/ace-step/data/models \
    INPUTS_DIR=/opt/ace-step/data/inputs \
    OUTPUTS_DIR=/opt/ace-step/data/outputs \
    RUNTIME_STATE_DIR=/opt/ace-step/data/state \
    PORT=7860 \
    SERVER_NAME=0.0.0.0 \
    LANGUAGE=en \
    ACESTEP_CONFIG_PATH=acestep-v15-turbo \
    ACESTEP_LM_MODEL_PATH=acestep-5Hz-lm-1.7B \
    ACESTEP_DEVICE=cuda \
    ACESTEP_LM_BACKEND=pt \
    ACESTEP_INIT_LLM=auto \
    ACESTEP_DOWNLOAD_SOURCE=auto \
    ACESTEP_NO_INIT=true \
    ACESTEP_EXTRA_ARGS= \
    PUID=1000 \
    PGID=1000 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    BOOTSTRAP_VENV=/opt/ace-step/bootstrap-venv \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/opt/ace-step/app/.venv

WORKDIR /opt/ace-step

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    ffmpeg \
    git \
    gosu \
    libsndfile1 \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python-is-python3 \
    tini \
 && rm -rf /var/lib/apt/lists/*

RUN python -m venv "${BOOTSTRAP_VENV}" \
 && "${BOOTSTRAP_VENV}/bin/pip" install --upgrade pip setuptools wheel uv

RUN git clone https://github.com/ace-step/ACE-Step-1.5.git "${APP_HOME}" \
 && cd "${APP_HOME}" \
 && git checkout "${ACE_STEP_REF}" \
 && "${BOOTSTRAP_VENV}/bin/uv" sync --no-dev

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
 && mkdir -p \
    "${MODELS_DIR}" \
    "${INPUTS_DIR}" \
    "${OUTPUTS_DIR}" \
    "${RUNTIME_STATE_DIR}" \
 && ACESTEP_GROUP="$(getent group 1000 | cut -d: -f1 || true)" \
 && if [ -z "${ACESTEP_GROUP}" ]; then groupadd --gid 1000 acestep; ACESTEP_GROUP=acestep; fi \
 && if ! id -u acestep >/dev/null 2>&1; then \
      if getent passwd 1000 >/dev/null; then \
        useradd --gid "${ACESTEP_GROUP}" --create-home --home-dir /home/acestep --shell /usr/sbin/nologin acestep; \
      else \
        useradd --uid 1000 --gid "${ACESTEP_GROUP}" --create-home --home-dir /home/acestep --shell /usr/sbin/nologin acestep; \
      fi; \
    fi \
 && chown -R "acestep:$(id -gn acestep)" \
    "${DATA_ROOT}" \
    /home/acestep

EXPOSE 7860/tcp

VOLUME ["/opt/ace-step/data/models", "/opt/ace-step/data/inputs", "/opt/ace-step/data/outputs", "/opt/ace-step/data/state"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=10 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:7860/', timeout=3)"

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
