# PaddleOCR-VL HPS Images

This directory contains the generic container packaging used by the `charts/paddleocr-vl` Helm chart.

The repository workflow `.github/workflows/paddleocr-vl-hps-image.yml` builds and publishes these images to GHCR:

- `ghcr.io/dafrenchyman/paddleocr-vl-gateway`
- `ghcr.io/dafrenchyman/paddleocr-vl-pipeline`

End users do not need to build these images locally to install the Helm chart. Local builds are only a maintainer verification path.

The images intentionally do not include a `prepare.sh` script. Helm owns release-specific runtime wiring by mounting the chart-rendered `pipeline_config.yaml` into the pipeline container.

## Docker Compose example

`docker-compose.example.yml` is provided for maintainer/local GPU testing of the same three-service topology used by the Helm chart:

```text
api -> pipeline -> vlm
```

Copy it to `docker-compose.yml` before editing local paths or GPU settings:

```bash
cp docker-compose.example.yml docker-compose.yml
```

The compose example mounts `pipeline_config.example.yaml` over the pipeline server config, matching the chart-owned `prepare.sh` replacement: `vl_recognition` uses `backend: vllm-server` and `server_url: http://vlm:8080/v1`.

Runtime model/cache downloads are written under `./local-data/`, which is ignored by this repository.
