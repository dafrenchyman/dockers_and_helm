# docling-serve

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.9.0](https://img.shields.io/badge/AppVersion-1.9.0-informational?style=flat-square)

A Helm chart for Docling-Serve, an API service wrapper for AI document conversion

**Homepage:** <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/docling-serve>

## Introduction

Docling-Serve is a FastAPI-based service that wraps the [Docling](https://github.com/docling-project/docling) document conversion toolkit, providing a REST API for converting document formats such as PDF and DOCX into structured formats like Markdown, JSON, and HTML.

This chart supports CPU and GPU image selection, local synchronous processing, Redis Queue-backed asynchronous processing, persistent model caching, and model pre-loading.

## Storage notes

The `docling-serve-cpu:v1.9.0` image runs as UID `1001`, sets `HOME=/opt/app-root/src`, and bakes default model artifacts into `/opt/app-root/src/.cache/docling/models`. When `modelCache.enabled=true`, this chart follows the Docling-Serve Kubernetes examples by setting `DOCLING_SERVE_ARTIFACTS_PATH` to `modelCache.mountPath` and mounting the model PVC there.

That model PVC is only the Docling artifacts directory. Runtime libraries may still write caches such as Hugging Face, XDG, or Torch caches, and Docling-Serve uses a scratch workspace for conversion results. Enable `runtimeCache` and `scratch` when you want those writes to land on explicit PVCs instead of the container writable layer or node ephemeral storage.

## Attribution

This chart started from the [khwong-c/helm-charts docling-serve chart](https://github.com/khwong-c/helm-charts/tree/main/charts/docling-serve). The templates and values were adapted for this repository's chart layout and README generation conventions.

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky http://charts.mrsharky.com
$ helm install my-release mrsharky/docling-serve
```

## Installing Chart from source

Verify everything is correct:

```bash
helm lint .
```

Install or upgrade:

```bash
helm upgrade --install docling-serve . -f values.yaml --wait --timeout 5m --atomic
```

Uninstall:

```bash
helm delete docling-serve
```

## Source Code

* <https://github.com/khwong-c/helm-charts/tree/main/charts/docling-serve>
* <https://github.com/docling-project/docling-serve>
* <https://github.com/docling-project/docling>
* <https://github.com/dafrenchyman/dockers_and_helm>

## Requirements

Kubernetes: `>=1.19.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules. |
| computeEngine.type | string | `"local"` | Compute engine type. Use `local` for synchronous processing or `rq` for Redis Queue-backed processing. |
| device.cudaDevices | string | `"cuda:0"` | CUDA devices specification used when `device.type` is `cuda`, such as `cuda:0` or `cuda:0,cuda:1`. |
| device.type | string | `"cpu"` | Device type used by Docling processing. Supported values are `cpu` and `cuda`. |
| env.custom | object | `{}` | Additional environment variables added as-is to the Docling-Serve container. |
| env.doclingPerf.elementsBatchSize | int | `8` | Number of elements processed per batch. |
| env.doclingPerf.numThreads | int | `4` | Number of Docling processing threads. |
| env.doclingPerf.pageBatchSize | int | `4` | Number of pages processed per batch. |
| env.doclingServe.enableRemoteServices | bool | `false` | Enable remote processing services. |
| env.doclingServe.enableUi | bool | `false` | Enable the Docling-Serve UI. |
| env.doclingServe.loadModelsAtBoot | bool | `false` | Pre-load models at container startup. |
| env.doclingServe.maxDocumentTimeout | int | `604800` | Maximum document result retention timeout in seconds. |
| env.doclingServe.singleUseResults | bool | `true` | Make conversion results available only once. |
| env.uvicorn.host | string | `"0.0.0.0"` | Uvicorn bind host. |
| env.uvicorn.port | int | `5001` | Uvicorn bind port. |
| env.uvicorn.reload | bool | `false` | Enable Uvicorn auto-reload. |
| env.uvicorn.workers | int | `1` | Number of Uvicorn workers. |
| fullnameOverride | string | `""` | Override full resource names. |
| global | object | `{}` | Global values passed through to chart templates. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"quay.io/docling-project/docling-serve-cpu"` | Container image repository. Use `quay.io/docling-project/docling-serve-cu126` for CUDA 12.6 GPU processing. |
| image.tag | string | `"v1.9.0"` | Image tag. Defaults to the chart appVersion when empty. |
| imagePullSecrets | list | `[]` | Image pull secrets. |
| ingress.annotations | object | `{}` | Ingress annotations. |
| ingress.className | string | `""` | Ingress class name. |
| ingress.enabled | bool | `false` | Enable ingress. |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts configuration. |
| ingress.tls | list | `[]` | Ingress TLS configuration. |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health","port":"http"},"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe configuration. |
| modelCache.accessMode | string | `"ReadWriteOnce"` | Model cache PVC access mode. |
| modelCache.enabled | bool | `false` | Enable persistent model cache PVC and mount. |
| modelCache.job.enabled | bool | `true` | Enable the model download Job when model cache is enabled. |
| modelCache.job.image | object | `{}` | Override image settings for the model download Job. Empty uses the main image settings. |
| modelCache.job.podSecurityContext | object | `{}` | Pod security context for the model download Job. Empty inherits `podSecurityContext`. |
| modelCache.job.resources | object | `{}` | Resource requests and limits for the model download Job. |
| modelCache.job.runtimeClassName | string | `""` | RuntimeClassName for the model download Job. Empty inherits `runtimeClassName`. |
| modelCache.job.securityContext | object | `{}` | Container security context for the model-loader container. Empty inherits `securityContext`. |
| modelCache.job.ttlSecondsAfterFinished | int | `100` | TTL in seconds after the model download Job finishes. |
| modelCache.models.all | bool | `false` | Download all available Docling models. |
| modelCache.models.list | list | `["layout","tableformer","picture_classifier","rapidocr","easyocr"]` | List of specific Docling models to download. The default list mirrors the models baked into the v1.9.0 container image. Common additional values include `code_formula`, `smolvlm`, and `granite_vision`. |
| modelCache.mountPath | string | `"/modelcache"` | Container mount path for the model cache. Also sets `DOCLING_SERVE_ARTIFACTS_PATH`. |
| modelCache.size | string | `"80Gi"` | Model cache PVC size. |
| modelCache.storageClass | string | `""` | StorageClass for the model cache PVC. Empty uses the cluster default StorageClass. |
| nameOverride | string | `""` | Override chart name. |
| nodeSelector | object | `{}` | Node selector. |
| podAnnotations | object | `{}` | Pod annotations. |
| podLabels | object | `{}` | Pod labels. |
| podSecurityContext | object | `{}` | Pod security context. |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health","port":"http"},"initialDelaySeconds":10,"periodSeconds":5,"timeoutSeconds":5}` | Readiness probe configuration. |
| redis.external.db | int | `0` | Redis database number. |
| redis.external.enabled | bool | `false` | Use an external Redis instance instead of deploying embedded Redis when `computeEngine.type` is `rq`. |
| redis.external.host | string | `""` | External Redis host. |
| redis.external.password | string | `""` | External Redis password. Stored in a generated Kubernetes Secret when set. |
| redis.external.port | int | `6379` | External Redis port. |
| redis.image.pullPolicy | string | `"IfNotPresent"` | Embedded Redis image pull policy. |
| redis.image.repository | string | `"redis"` | Embedded Redis image repository. |
| redis.image.tag | string | `"7-alpine"` | Embedded Redis image tag. |
| redis.resources | object | `{}` | Embedded Redis resource requests and limits. |
| replicaCount | int | `1` | Number of Docling-Serve replicas. |
| resources | object | `{}` | Container resource requests and limits. |
| runtimeCache.accessMode | string | `"ReadWriteOnce"` | Runtime cache PVC access mode. |
| runtimeCache.enabled | bool | `false` | Enable a PVC for runtime library caches such as Hugging Face, XDG, and Torch caches. This keeps unexpected model/library downloads out of the container writable layer. |
| runtimeCache.existingClaim | string | `""` | Existing PVC claim name for runtime caches. When set, no runtime cache PVC is created. |
| runtimeCache.mountPath | string | `"/cache"` | Container mount path for runtime caches. |
| runtimeCache.setHuggingFaceHome | bool | `true` | Set `HF_HOME` to `runtimeCache.mountPath`/huggingface. |
| runtimeCache.setTorchHome | bool | `true` | Set `TORCH_HOME` to `runtimeCache.mountPath`/torch. |
| runtimeCache.setXdgCacheHome | bool | `true` | Set `XDG_CACHE_HOME` to `runtimeCache.mountPath`/xdg. |
| runtimeCache.size | string | `"20Gi"` | Runtime cache PVC size. |
| runtimeCache.storageClass | string | `""` | StorageClass for the runtime cache PVC. Empty uses the cluster default StorageClass. |
| runtimeClassName | string | `""` | RuntimeClassName for Docling-Serve pods, such as `nvidia` when GPU workloads require the NVIDIA runtime. |
| scratch.accessMode | string | `"ReadWriteOnce"` | Scratch PVC access mode. |
| scratch.enabled | bool | `false` | Enable a PVC for Docling-Serve scratch files and conversion results. This sets `DOCLING_SERVE_SCRATCH_PATH`. |
| scratch.existingClaim | string | `""` | Existing PVC claim name for scratch storage. When set, no scratch PVC is created. |
| scratch.mountPath | string | `"/scratch"` | Container mount path for scratch files and conversion results. |
| scratch.setGradioTempDir | bool | `true` | Also set `GRADIO_TEMP_DIR` to `scratch.mountPath` when the UI is enabled. |
| scratch.size | string | `"20Gi"` | Scratch PVC size. |
| scratch.storageClass | string | `""` | StorageClass for the scratch PVC. Empty uses the cluster default StorageClass. |
| securityContext | object | `{}` | Container security context. |
| service.port | int | `5001` | Service port. |
| service.type | string | `"ClusterIP"` | Service type. |
| tolerations | list | `[]` | Tolerations. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
