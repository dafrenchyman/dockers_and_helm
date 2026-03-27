# ace-step-1-5

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: eddb621](https://img.shields.io/badge/AppVersion-eddb621-informational?style=flat-square)

ACE-Step 1.5 Gradio web UI with four-tier persistent storage

**Homepage:** <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/ace-step-1-5>

## Additional Information

Chart uses the awesome common library from [bjw-s-labs](https://bjw-s-labs.github.io/helm-charts/)

This chart assumes an NVIDIA-backed workload and separates persistence into four tiers:

- model storage
- user-provided inputs
- generated outputs
- smaller runtime state for config, caches, logs, and temporary files

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky http://charts.mrsharky.com
$ helm install my-release mrsharky/ace-step-1-5
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
helm upgrade --install ace-step-1-5 . -f values.yaml --wait --timeout 5m --atomic
```

Uninstall

```bash
helm delete ace-step-1-5
```

## Packaging
```bash
helm package ace-step-1-5
helm repo index . --url https://charts.mrsharky.com
```

## Source Code

* <https://github.com/ace-step/ACE-Step-1.5>
* <https://github.com/dafrenchyman/dockers_and_helm>
* <https://bjw-s-labs.github.io/helm-charts/>

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://bjw-s-labs.github.io/helm-charts/ | common | 4.3.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aceStep.configPath | string | `"acestep-v15-turbo"` | Default DiT model selection passed as `ACESTEP_CONFIG_PATH`. |
| aceStep.device | string | `"cuda"` | Device selection forwarded to ACE-Step. Use `cuda` for the intended NVIDIA-backed deployment profile, or override only if you know the upstream runtime supports your hardware combination. |
| aceStep.downloadSource | string | `"auto"` | Preferred model download source. Supported values are `auto`, `huggingface`, and `modelscope`. |
| aceStep.extraArgs | string | `""` | Additional arguments appended to the ACE-Step Gradio launch command. This is the escape hatch for upstream options not modeled directly by the chart. Leave it empty for the documented default behavior. |
| aceStep.gid | string | `"1000"` | The GID that should own writable mounted paths inside the container. The chart also exposes pod-level security context controls, which are the primary ownership mechanism for Kubernetes. |
| aceStep.host | string | `"0.0.0.0"` | Listen address passed to the Gradio web UI. The default `0.0.0.0` matches the container's remote-access behavior and is required for ingress or Service-based access to work correctly. |
| aceStep.initLlm | string | `"auto"` | LLM initialization mode. The default `auto` lets ACE-Step choose the LM initialization behavior based on the detected GPU configuration. |
| aceStep.language | string | `"en"` | UI language passed to ACE-Step. Supported values depend on upstream and currently include `en`, `zh`, `he`, and `ja`. |
| aceStep.lmBackend | string | `"pt"` | Language-model backend forwarded to ACE-Step. The default `pt` favors compatibility on consumer GPUs over the more aggressive `vllm` path. |
| aceStep.lmModelPath | string | `"acestep-5Hz-lm-1.7B"` | Default language-model selection passed as `ACESTEP_LM_MODEL_PATH`. This controls the optional 5Hz LM chosen when ACE-Step decides to load it. |
| aceStep.noInit | bool | `true` | Skip eager model initialization during startup so the web UI can come up faster. The default `true` follows ACE-Step's newer on-demand initialization flow so models are loaded when needed by the user workflow. |
| aceStep.port | int | `7860` | Main ACE-Step 1.5 web port exposed by the container. |
| aceStep.replicas | int | `1` | Replica count for the main deployment. Keep this at 1 unless you know the storage and runtime behavior works for your workload. The writable storage model in this chart is designed around a single-writer deployment by default. |
| aceStep.timezone | string | `"America/Los_Angeles"` | Optional timezone passed through to the container for log timestamps and any runtime behavior that depends on local time. |
| aceStep.uid | string | `"1000"` | The UID that should own writable mounted paths inside the container. This matters most for hostPath-style storage and other bind-mounted Kubernetes volumes where you care about host-visible file ownership. |
| affinity | object | `{}` | Optional affinity overrides. |
| containerSecurityContext | object | `{}` | Optional container-level security context overrides. Leave empty unless you need to set capabilities, readOnlyRootFilesystem, seccompProfile, or similar low-level container settings. |
| controllers | object | `{}` | Optional controller override. When left empty, the chart generates the main controller from the documented settings above. Most users should leave this empty and configure the workload through the higher-level values in this file so the generated README remains accurate. |
| defaultPodOptions | object | `{}` | Optional default pod options override. When left empty, the chart creates pod defaults from the documented values above. Advanced users can override this if they need to bypass the chart's default fsGroup behavior entirely. |
| global | object | `{}` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the ACE-Step 1.5 container. Leave this at `IfNotPresent` for stable nodes, or switch to `Always` if you rely on mutable tags such as `latest`. |
| image.repository | string | `"ghcr.io/dafrenchyman/ace-step-1-5"` | ACE-Step 1.5 image repository. |
| image.tag | string | `"latest"` | ACE-Step 1.5 image tag. `latest` tracks the latest main build. |
| ingress.main.annotations | object | `{}` |  |
| ingress.main.className | string | `"nginx"` |  |
| ingress.main.enabled | bool | `false` |  |
| ingress.main.hosts[0].host | string | `"ace-step-1-5.nixoskubemini.home.arpa"` |  |
| ingress.main.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.main.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.main.hosts[0].paths[0].service.identifier | string | `"main"` |  |
| ingress.main.hosts[0].paths[0].service.port | string | `"http"` |  |
| ingress.main.tls | list | `[]` |  |
| nodeSelector | object | `{}` | Optional node selector overrides. |
| persistence.inputs | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/ace-step/data/inputs","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/ace-step-1-5/inputs","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | User-provided reference material and other uploaded input assets. Keep this separate from `outputs` if you want incoming files to live on a different storage class, or if you want a clearer operational boundary between user uploads and generated content. |
| persistence.models | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/ace-step/data/models","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/ace-step-1-5/models","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Models, checkpoints, and other large downloadable ACE-Step assets. This path is usually best placed on fast storage such as local NVMe. The container redirects the primary ACE-Step model root into this path. |
| persistence.outputs | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/ace-step/data/outputs","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/ace-step-1-5/outputs","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Generated songs and related output artifacts. This path can usually use slower capacity-oriented storage than the model assets. Keep this separate from `models` if you want to place generated content on larger but slower storage. |
| persistence.runtime-state | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/ace-step/data/state","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/ace-step-1-5/state","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Smaller runtime state including config, caches, logs, and temporary files. The container redirects model and downloader cache roots into this volume so runtime state stays inside documented persistent storage instead of leaking into implicit home-directory caches. |
| podSecurityContext.fsGroup | int | `1000` | Apply a filesystem group so mounted volumes are writable by the runtime group even when the storage backend preserves ownership metadata. |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` | Only recurse ownership changes when Kubernetes detects a root mismatch. This reduces avoidable startup churn on large persistent volumes. |
| resources.limits."nvidia.com/gpu" | int | `1` |  |
| resources.requests | object | `{"cpu":"500m","memory":"4Gi"}` | GPU-enabled music-generation workloads can be memory hungry. Adjust CPU, memory, and GPU requests to match your node capacity and scheduling requirements. The default GPU limit assumes an NVIDIA device plugin is installed and that this workload should reserve one GPU. No memory limit is set by default because model initialization and generation can spike usage. |
| service.main.controller | string | `"main"` |  |
| service.main.enabled | bool | `true` |  |
| service.main.ports.http.port | int | `7860` |  |
| service.main.ports.http.protocol | string | `"TCP"` |  |
| service.main.ports.http.targetPort | string | `"web"` |  |
| service.main.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` | Optional toleration overrides. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
