ARG BASE_IMAGE=ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlex/hps:paddlex3.6-gpu@sha256:033e882c841cc6ef772b06b4b34d60f86140a33d189680cc8f9a14d7c35b979d
FROM ${BASE_IMAGE}

ARG HPS_PIPELINE_NAME=PaddleOCR-VL-1.6
ARG HPS_PADDLEX_VERSION=3.6
ARG HPS_SDK_VERSION=v${HPS_PADDLEX_VERSION}
ARG HPS_SDK_DIR=paddlex_hps_${HPS_PIPELINE_NAME}_sdk
ARG HPS_SDK_URL=https://paddle-model-ecology.bj.bcebos.com/paddlex/PaddleX3.0/deploy/paddlex_hps/public/sdks/${HPS_SDK_VERSION}/${HPS_SDK_DIR}.tar.gz
ARG DEVICE_TYPE=gpu

RUN apt-get update     && apt-get install -y --no-install-recommends ca-certificates curl     && rm -rf /var/lib/apt/lists/*

RUN set -eux;     mkdir -p /tmp/paddleocr-vl-sdk /opt/paddleocr-vl;     curl -fsSL "${HPS_SDK_URL}" -o /tmp/paddleocr-vl-sdk/sdk.tar.gz;     tar -xzf /tmp/paddleocr-vl-sdk/sdk.tar.gz -C /tmp/paddleocr-vl-sdk;     cp -a "/tmp/paddleocr-vl-sdk/${HPS_SDK_DIR}/server" /opt/paddleocr-vl/server;     rm -rf /tmp/paddleocr-vl-sdk

WORKDIR /opt/paddleocr-vl/server

ENV PADDLEX_HPS_DEVICE_TYPE=${DEVICE_TYPE}

CMD ["/bin/bash", "server.sh"]
