# paddleocr-vl

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: PaddleOCR-VL-1.6](https://img.shields.io/badge/AppVersion-PaddleOCR--VL--1.6-informational?style=flat-square)

PaddleOCR-VL high-performance OCR/document parsing API

**Homepage:** <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/paddleocr-vl>

## Additional Information

Chart uses the awesome common library from [bjw-s-labs](https://bjw-s-labs.github.io/helm-charts/).

This chart deploys the official PaddleOCR-VL high-performance serving backend topology:

```text
Client -> FastAPI Gateway -> Triton Server -> vLLM Server
```

The default API and pipeline images are published by this repository's GHCR workflow. Users do not need to build local images to install the chart. The VLM server uses the official NVIDIA GPU image, digest-pinned in `values.yaml`.

The official gateway exposes:

- `GET /health`
- `GET /health/ready`
- `POST /layout-parsing`
- `POST /restructure-pages`

First startup downloads PaddleX/PaddleOCR/vLLM model files to `/cache` when `persistence.pipeline-cache.enabled=true` and `persistence.vlm-cache.enabled=true`. Subsequent starts reuse `${PADDLE_PDX_CACHE_HOME}/official_models` plus Hugging Face, ModelScope, and vLLM cache directories under `/cache`.

### NixOS / NVIDIA GPU notes

For NixOS/NVIDIA Docker environments, keep `NVIDIA_VISIBLE_DEVICES=0`, `NVIDIA_DRIVER_CAPABILITIES=compute,utility`, and `TRITON_LIBCUDA_PATH=/usr/lib/x86_64-linux-gnu` on the GPU containers unless the cluster runtime already provides a working CUDA library path.

Observed failure mode from the PaddleOCR-VL research: GPU containers could run `nvidia-smi`, and `libcuda.so.1` existed at `/usr/lib/x86_64-linux-gnu/libcuda.so.1`, but vLLM/Triton failed with `AssertionError: libcuda.so cannot found!` because `ldconfig`/the dynamic linker path did not make that library discoverable. Pointing `TRITON_LIBCUDA_PATH` directly at `/usr/lib/x86_64-linux-gnu` fixes the CUDA discovery path.

Use this override as the NixOS baseline:

```yaml
gpu:
  nvidiaVisibleDevices: "0"
  driverCapabilities: compute,utility
  tritonLibcudaPath: /usr/lib/x86_64-linux-gnu
# Optional only for clusters that require an NVIDIA RuntimeClass:
# runtimeClassName: nvidia
```

Omit `runtimeClassName` when the cluster only needs the NVIDIA device plugin and `nvidia.com/gpu` limits. Set `runtimeClassName: nvidia` only when your cluster runtime requires it.

The default chart requests `nvidia.com/gpu: 1` on both `pipeline` and `vlm` because the standard Kubernetes NVIDIA device-plugin path injects GPU devices per container that requests the resource. This reserves two GPUs by default. Single-GPU operators can intentionally configure NVIDIA device-plugin time slicing/oversubscription, expose the same device with runtime-specific settings, or override one controller's GPU limit only after confirming `nvidia-smi` and the serving process work in both GPU containers.

### vLLM sleep mode

vLLM online sleep mode can release most GPU memory, but it requires development endpoints. This chart keeps sleep mode disabled by default and never exposes the VLM Service through ingress.

Relevant values:

```yaml
vlm:
  sleepMode:
    enabled: true
    devMode: true
  backendConfig:
    gpu-memory-utilization: null
    max-num-seqs: null
  extraArgs: []
```

When `vlm.sleepMode.enabled=true`, the chart sets `VLLM_SERVER_DEV_MODE=1` when `vlm.sleepMode.devMode=true`, generates `/config/vllm_config.yaml` with `enable-sleep-mode: true`, and passes it to `paddleocr genai_server --backend_config`.

Internal-only sleep/wake commands:

```bash
curl -X POST 'http://<vlm-service>:8080/sleep?level=1'
curl -X POST 'http://<vlm-service>:8080/wake_up'
curl -sS 'http://<vlm-service>:8080/is_sleeping'
```

Do not expose VLM development endpoints through ingress.

### API ingress

The API gateway uses a normal ClusterIP Service behind Ingress. The chart does not use NodePort or LoadBalancer by default.

```yaml
ingress:
  api:
    enabled: true
    className: nginx
    hosts:
      - host: paddleocr-vl.example.local
        paths:
          - path: /
            pathType: Prefix
            service:
              identifier: api
              port: http
    tls: []
```

The backend is intentionally unauthenticated by default. For production, keep the Service as `ClusterIP` and put authentication at the ingress, API gateway, or caller-service layer before traffic reaches PaddleOCR. Examples: nginx ingress auth annotations, oauth2-proxy, Authelia, Traefik forward-auth, or an application service that calls PaddleOCR internally. This chart does not add API keys to the official gateway because upstream `gateway/app.py` has no auth path, and adding one would require owning a forked API contract.

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky https://charts.mrsharky.com/
$ helm install my-release mrsharky/paddleocr-vl
```

## Installing Chart from source

Get the dependencies

```bash
helm dependency update
```

Verify everything is correct

```bash
helm lint .
```

Install/Upgrade

```bash
helm upgrade --install paddleocr-vl . -f values.yaml --wait --timeout 30m --atomic
```

Uninstall

```bash
helm delete paddleocr-vl
```

## Packaging
```bash
helm package paddleocr-vl
helm repo index . --url https://charts.mrsharky.com/
```

## Source Code

* <https://github.com/dafrenchyman/dockers_and_helm>
* <https://github.com/PaddlePaddle/PaddleOCR>
* <https://bjw-s-labs.github.io/helm-charts/>

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://bjw-s-labs.github.io/helm-charts/ | common | 4.3.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Optional affinity overrides. |
| containerSecurityContext | object | `{}` | Optional container-level security context overrides. |
| controllers | object | `{}` | Optional controller override. When a matching key is present, that controller is not generated by this chart. |
| defaultPodOptions | object | `{}` | Optional default pod options override. When left empty, the chart creates pod defaults from the documented values above. |
| global | object | `{}` |  |
| gpu.deviceId | string | `"0"` | `HPS_DEVICE_ID` passed to GPU containers. |
| gpu.driverCapabilities | string | `"compute,utility"` | `NVIDIA_DRIVER_CAPABILITIES` passed to GPU containers. |
| gpu.nvidiaVisibleDevices | string | `"0"` | `NVIDIA_VISIBLE_DEVICES` passed to GPU containers. |
| gpu.tritonLibcudaPath | string | `"/usr/lib/x86_64-linux-gnu"` | `TRITON_LIBCUDA_PATH` for vLLM/Triton CUDA discovery. In the supplied NixOS/Docker GPU environment, `nvidia-smi` worked and `/usr/lib/x86_64-linux-gnu/libcuda.so.1` existed, but `ldconfig`/the dynamic linker did not expose `libcuda.so`; pointing directly at this directory fixed `AssertionError: libcuda.so cannot found!`. |
| image.api.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the API gateway container. |
| image.api.repository | string | `"ghcr.io/dafrenchyman/paddleocr-vl-gateway"` | Repo-published PaddleOCR-VL FastAPI gateway image repository. |
| image.api.tag | string | `"latest"` | Start with `latest` only until the first GHCR workflow publish creates sha-* tags; then replace this default with the first verified `sha-...` tag. |
| image.pipeline.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the pipeline container. |
| image.pipeline.repository | string | `"ghcr.io/dafrenchyman/paddleocr-vl-pipeline"` | Repo-published PaddleOCR-VL Triton pipeline image repository. |
| image.pipeline.tag | string | `"latest"` | Start with `latest` only until the first GHCR workflow publish creates sha-* tags; then replace this default with the first verified `sha-...` tag. |
| image.vlm.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the VLM server container. |
| image.vlm.repository | string | `"ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/paddleocr-genai-vllm-server"` | Official PaddleOCR generative vLLM server image repository. |
| image.vlm.tag | string | `"latest-nvidia-gpu@sha256:5713fd30ab76094b7b6a20d95fd8e26fa9dc452bcc90ccb16f1fb056bd2a0f4d"` | Digest-pinned form of upstream `latest-nvidia-gpu`; this SHA is for the NVIDIA GPU image. Inspected on 2026-07-26 with `docker buildx imagetools inspect`. |
| ingress.api.annotations | object | `{}` | Optional ingress annotations for authentication, TLS helpers, rewrites, etc. |
| ingress.api.className | string | `"nginx"` | IngressClass to use when ingress is enabled. |
| ingress.api.enabled | bool | `false` | Enable an ingress for the API gateway. Disabled by default because the official gateway has no authentication. |
| ingress.api.hosts[0].host | string | `"paddleocr-vl.example.local"` |  |
| ingress.api.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.api.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.api.hosts[0].paths[0].service.identifier | string | `"api"` |  |
| ingress.api.hosts[0].paths[0].service.port | string | `"http"` |  |
| ingress.api.tls | list | `[]` | Optional TLS entries for HTTPS-enabled ingress setups. |
| nodeSelector | object | `{}` | Optional node selector overrides. |
| paddleocr.disableModelSourceCheck | bool | `false` | Set true to export `PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True` and skip PaddleX source reachability HEAD checks. |
| paddleocr.modelSource | string | `"huggingface"` | PaddleX model source. Source-verified aliases: `huggingface`, `aistudio`, `modelscope`, `bos`. |
| paddleocr.paddlexVersion | string | `"3.6"` | PaddleX HPS SDK/base-image major.minor version. Official HPS default for PaddleOCR-VL-1.6 is `3.6`. |
| paddleocr.pipelineName | string | `"PaddleOCR-VL-1.6"` | PaddleOCR-VL pipeline release. Known official HPS examples: `PaddleOCR-VL-1.6`, `PaddleOCR-VL-1.5`, `PaddleOCR-VL`. |
| paddleocr.replicas.api | int | `1` | Number of API gateway replicas. |
| paddleocr.replicas.pipeline | int | `1` | Number of Triton pipeline replicas. |
| paddleocr.replicas.vlm | int | `1` | Number of VLM server replicas. |
| paddleocr.sdkDir | string | `"paddlex_hps_PaddleOCR-VL-1.6_sdk"` | SDK directory name matching `paddlex_hps_${pipelineName}_sdk`; examples: `paddlex_hps_PaddleOCR-VL-1.6_sdk`, `paddlex_hps_PaddleOCR-VL-1.5_sdk`, `paddlex_hps_PaddleOCR-VL_sdk`. |
| paddleocr.vlmName | string | `"PaddleOCR-VL-1.6-0.9B"` | VLM service model. Known official example for the 1.6 pipeline: `PaddleOCR-VL-1.6-0.9B`; 1.5 uses `PaddleOCR-VL-1.5-0.9B`; v1 uses `PaddleOCR-VL-0.9B`. |
| persistence.pipeline-cache | object | `{"accessMode":"ReadWriteOnce","advancedMounts":{"pipeline":{"app":[{"path":"/cache","readOnly":false}]}},"enabled":true,"size":"50Gi","type":"persistentVolumeClaim"}` | Pipeline model/cache PVC. Advanced users can switch `type` to `hostPath` for local NVMe-backed storage, or intentionally use an RWX existing claim after validating sharing semantics. |
| persistence.runtime-state | object | `{"accessMode":"ReadWriteOnce","advancedMounts":{"api":{"app":[{"path":"/state","readOnly":false}]},"pipeline":{"app":[{"path":"/state","readOnly":false}]},"vlm":{"app":[{"path":"/state","readOnly":false}]}},"enabled":false,"size":"20Gi","type":"persistentVolumeClaim"}` | Optional smaller runtime state for logs/tmp. When enabled, this mounts `/state` on all controllers and sets `TMPDIR=/state/tmp`. |
| persistence.vlm-cache | object | `{"accessMode":"ReadWriteOnce","advancedMounts":{"vlm":{"app":[{"path":"/cache","readOnly":false}]}},"enabled":true,"size":"100Gi","type":"persistentVolumeClaim"}` | VLM model/cache PVC. Default is separate from `pipeline-cache` because one shared RWO PVC across separate Pods is not portable. |
| podSecurityContext.fsGroup | int | `1000` | Apply a filesystem group so mounted volumes are writable by the runtime group even when the storage backend preserves ownership metadata. |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` | Only recurse ownership changes when Kubernetes detects a root mismatch. |
| resources.api | object | `{}` | API gateway resources. No GPU env, runtimeClass, or GPU resource is applied to this controller by default. |
| resources.pipeline.limits | object | `{"nvidia.com/gpu":1}` | Triton pipeline limits. This GPU limit is intentionally present by default so the NVIDIA device plugin injects GPU devices. |
| resources.pipeline.requests | object | `{"cpu":"1000m","memory":"8Gi"}` | Triton pipeline resource requests. |
| resources.vlm.limits | object | `{"nvidia.com/gpu":1}` | VLM server limits. This GPU limit is intentionally present by default so the NVIDIA device plugin injects GPU devices. |
| resources.vlm.requests | object | `{"cpu":"1000m","memory":"16Gi"}` | VLM server resource requests. |
| runtimeClassName | string | `""` | Optional RuntimeClass for GPU Pods. Set to `nvidia` only on clusters that require an NVIDIA RuntimeClass; otherwise leave empty and rely on the NVIDIA device plugin plus `nvidia.com/gpu` limits. |
| service.api.controller | string | `"api"` |  |
| service.api.enabled | bool | `true` | Create a ClusterIP Service for the FastAPI gateway. |
| service.api.ports.http.port | int | `8080` |  |
| service.api.ports.http.protocol | string | `"TCP"` |  |
| service.api.ports.http.targetPort | string | `"http"` |  |
| service.api.type | string | `"ClusterIP"` |  |
| service.pipeline.controller | string | `"pipeline"` |  |
| service.pipeline.enabled | bool | `true` | Create an internal ClusterIP Service for the Triton pipeline. |
| service.pipeline.ports.grpc.port | int | `8001` |  |
| service.pipeline.ports.grpc.protocol | string | `"TCP"` |  |
| service.pipeline.ports.grpc.targetPort | string | `"grpc"` |  |
| service.pipeline.ports.http.port | int | `8000` |  |
| service.pipeline.ports.http.protocol | string | `"TCP"` |  |
| service.pipeline.ports.http.targetPort | string | `"http"` |  |
| service.pipeline.type | string | `"ClusterIP"` |  |
| service.vlm.controller | string | `"vlm"` |  |
| service.vlm.enabled | bool | `true` | Create an internal ClusterIP Service for the VLM server. |
| service.vlm.ports.http.port | int | `8080` |  |
| service.vlm.ports.http.protocol | string | `"TCP"` |  |
| service.vlm.ports.http.targetPort | string | `"http"` |  |
| service.vlm.type | string | `"ClusterIP"` |  |
| serving.filterHealthAccessLog | bool | `true` | `HPS_FILTER_HEALTH_ACCESS_LOG`; hides health access logs in the official gateway. |
| serving.healthCheckTimeoutSeconds | int | `5` | `HPS_HEALTH_CHECK_TIMEOUT` in seconds. |
| serving.inferenceTimeoutSeconds | int | `600` | `HPS_INFERENCE_TIMEOUT` in seconds. |
| serving.logLevel | string | `"INFO"` | `HPS_LOG_LEVEL`. |
| serving.maxConcurrentInferenceRequests | int | `16` | `HPS_MAX_CONCURRENT_INFERENCE_REQUESTS` for gateway inference calls. |
| serving.maxConcurrentNonInferenceRequests | int | `64` | `HPS_MAX_CONCURRENT_NON_INFERENCE_REQUESTS` for gateway non-inference calls. |
| serving.uvicornWorkers | int | `4` | `HPS_UVICORN_WORKERS` for the FastAPI gateway. |
| tolerations | list | `[]` | Optional toleration overrides. |
| vlm.backend | string | `"vllm"` |  |
| vlm.backendConfig | object | `{"gpu-memory-utilization":null,"max-num-seqs":null}` | Optional generated backend config mounted at `/config/vllm_config.yaml` and passed with `--backend_config` when any key is set. |
| vlm.backendConfig.gpu-memory-utilization | string | `nil` | Optional vLLM GPU memory utilization; leave null to omit from generated backend config. |
| vlm.backendConfig.max-num-seqs | string | `nil` | Optional vLLM max sequence count; leave null to omit from generated backend config. |
| vlm.extraArgs | list | `[]` | Extra args appended to `paddleocr genai_server` for upstream options not modeled by this chart. |
| vlm.modelDir | string | `""` | Optional local model directory passed as `--model_dir` when non-empty. |
| vlm.sleepMode.devMode | bool | `true` | Sets `VLLM_SERVER_DEV_MODE=1`; required for vLLM online sleep/wake endpoints. |
| vlm.sleepMode.enabled | bool | `false` | Enables vLLM development endpoints plus sleep mode. These endpoints must stay internal. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
