FROM nvidia/cuda:12.4.1-base-ubuntu22.04

LABEL maintainer="julien.pierret@gmail.com"
LABEL org.opencontainers.image.title="Fooocus_extend"
LABEL org.opencontainers.image.description="Pinned Fooocus_extend image with seeded presets, styles, and wildcards"
LABEL org.opencontainers.image.source="https://github.com/dafrenchyman/dockers_and_helm"

ARG DEBIAN_FRONTEND=noninteractive
ARG FOOOCUS_EXTEND_REF=67c346a74bb5bbdce1e84f37e0bc77d22a0ae456

ENV APP_HOME=/content/app \
    DATA_ROOT=/content/data \
    CMDARGS=--listen \
    PUID=1000 \
    PGID=1000 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# System packages cover:
# - build tooling for native Python wheels such as insightface
# - runtime helpers like gosu/tini
# - graphics/runtime libs expected by Fooocus_extend
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    gosu \
    libgl1 \
    libglib2.0-0 \
    python3-dev \
    python3-pip \
    python-is-python3 \
    tini \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN addgroup --gid 1000 fooocus \
 && adduser --disabled-password --gecos '' --uid 1000 --gid 1000 fooocus \
 && mkdir -p /content/app /content/data /content/defaults

WORKDIR /content

# Clone the app source at a pinned commit so image builds stay reproducible.
RUN git clone https://github.com/shaitanzx/Fooocus_extend.git /content/app \
 && cd /content/app \
 && git checkout "${FOOOCUS_EXTEND_REF}"

# Install the app's declared Python stack at build time to avoid first-start
# dependency churn for the base runtime.
RUN pip install --no-cache-dir \
    -r /content/app/requirements_docker.txt \
    -r /content/app/requirements_versions.txt \
 && pip install --no-cache-dir xformers==0.0.23 --no-dependencies

# Keep Gradio's FRP helper in the location expected by the upstream runtime.
COPY requirements.pinned.txt /tmp/requirements.pinned.txt
RUN pip install --no-cache-dir -r /tmp/requirements.pinned.txt \
 && rm -f /tmp/requirements.pinned.txt

RUN curl -fsL -o /usr/local/lib/python3.10/dist-packages/gradio/frpc_linux_amd64_v0.2 https://cdn-media.huggingface.co/frpc-gradio-0.2/frpc_linux_amd64 \
 && chmod +x /usr/local/lib/python3.10/dist-packages/gradio/frpc_linux_amd64_v0.2

# Copy repo-managed assets late in the build so style/wildcard/sample tweaks do
# not invalidate the expensive dependency-install layers above.
COPY presets /tmp/repo-presets
COPY style /tmp/repo-styles
COPY wildcards /tmp/repo-wildcards

# Merge repo-managed defaults into the application tree, snapshot them into
# /content/defaults for runtime seeding, then rename the original live paths so
# the entrypoint can replace them with persistent-storage symlinks.
RUN cp -a /tmp/repo-presets/. /content/app/presets/ \
 && cp -a /tmp/repo-styles/. /content/app/sdxl_styles/ \
 && cp -a /tmp/repo-wildcards/. /content/app/wildcards/ \
 && cp -a /content/app/presets /content/defaults/presets \
 && cp -a /content/app/sdxl_styles /content/defaults/sdxl_styles \
 && cp -a /content/app/wildcards /content/defaults/wildcards \
 && cp -a /content/app/models /content/defaults/models \
 && mv /content/app/models /content/app/models.org \
 && mv /content/app/presets /content/app/presets.org \
 && mv /content/app/sdxl_styles /content/app/sdxl_styles.org \
 && mv /content/app/wildcards /content/app/wildcards.org \
 && rm -rf /tmp/repo-presets /tmp/repo-styles /tmp/repo-wildcards

COPY entrypoint.sh /content/entrypoint.sh

# The container starts as root only long enough to fix ownership on mounted
# paths, then drops to the fooocus user via gosu in entrypoint.sh.
RUN chmod +x /content/entrypoint.sh \
 && chown -R fooocus:fooocus /content

EXPOSE 7865/tcp

VOLUME ["/content/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=5 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:7865/', timeout=3)"

ENTRYPOINT ["/usr/bin/tini", "--", "/content/entrypoint.sh"]
