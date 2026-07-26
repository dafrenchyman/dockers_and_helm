FROM python:3.10-slim

ARG HPS_PIPELINE_NAME=PaddleOCR-VL-1.6
ARG HPS_PADDLEX_VERSION=3.6
ARG HPS_SDK_VERSION=v${HPS_PADDLEX_VERSION}
ARG HPS_SDK_DIR=paddlex_hps_${HPS_PIPELINE_NAME}_sdk
ARG HPS_SDK_URL=https://paddle-model-ecology.bj.bcebos.com/paddlex/PaddleX3.0/deploy/paddlex_hps/public/sdks/${HPS_SDK_VERSION}/${HPS_SDK_DIR}.tar.gz

RUN apt-get update     && apt-get install -y --no-install-recommends ca-certificates curl libgl1 libglib2.0-0     && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app.py requirements.txt ./

RUN set -eux;     mkdir -p /tmp/paddleocr-vl-sdk;     curl -fsSL "${HPS_SDK_URL}" -o /tmp/paddleocr-vl-sdk/sdk.tar.gz;     tar -xzf /tmp/paddleocr-vl-sdk/sdk.tar.gz -C /tmp/paddleocr-vl-sdk;     python -m pip install --no-cache-dir -r requirements.txt;     python -m pip install --no-cache-dir -r "/tmp/paddleocr-vl-sdk/${HPS_SDK_DIR}/client/requirements.txt";     python -m pip install --no-cache-dir /tmp/paddleocr-vl-sdk/${HPS_SDK_DIR}/client/paddlex_hps_client-*.whl;     rm -rf /tmp/paddleocr-vl-sdk

ENV HPS_TRITON_URL=paddleocr-vl-pipeline:8001     HPS_MAX_CONCURRENT_INFERENCE_REQUESTS=16     HPS_MAX_CONCURRENT_NON_INFERENCE_REQUESTS=64     HPS_INFERENCE_TIMEOUT=600     HPS_HEALTH_CHECK_TIMEOUT=5     HPS_LOG_LEVEL=INFO     HPS_FILTER_HEALTH_ACCESS_LOG=true     HPS_UVICORN_WORKERS=4

EXPOSE 8080

CMD uvicorn --host 0.0.0.0 --port 8080 --workers ${HPS_UVICORN_WORKERS} app:app
