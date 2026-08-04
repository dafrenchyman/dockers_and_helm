ARG TURBOWARP_REF=a2946eeb9a9dca7857d7ab53d766b54288c7a2ff
ARG LSIO_NGINX_TAG=1.30.4-r1-ls369

FROM node:22-bookworm AS build

ARG TURBOWARP_REF

WORKDIR /src

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/TurboWarp/scratch-gui.git . \
 && git checkout "${TURBOWARP_REF}"

RUN npm ci

ENV NODE_ENV=production

RUN npm run build

FROM lscr.io/linuxserver/nginx:${LSIO_NGINX_TAG}

ARG LSIO_NGINX_TAG

LABEL org.opencontainers.image.title="TurboWarp"
LABEL org.opencontainers.image.description="Pinned TurboWarp GUI static web image using LinuxServer.io nginx runtime"
LABEL org.opencontainers.image.source="https://github.com/dafrenchyman/dockers_and_helm"

ENV LSIO_NGINX_TAG=${LSIO_NGINX_TAG} \
    PUID=1000 \
    PGID=1000 \
    TZ=Etc/UTC \
    UMASK=022

COPY --from=build /src/build /opt/turbowarp/www
COPY nginx.conf /opt/turbowarp/default.conf
COPY root/ /

RUN chmod +x /custom-cont-init.d/10-turbowarp-assets

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1/editor.html || exit 1
