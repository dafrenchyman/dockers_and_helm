# fooocus_extend

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 67c346a](https://img.shields.io/badge/AppVersion-67c346a-informational?style=flat-square)

Fooocus_extend with repo-managed seeded presets, styles, and wildcards

**Homepage:** <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/fooocus_extend>

## Additional Information

Chart uses the awesome common library from [bjw-s-labs](https://bjw-s-labs.github.io/helm-charts/)

This chart assumes an NVIDIA-backed workload and separates persistence into three tiers:

- fast model storage
- generated outputs
- smaller runtime state for config, presets, styles, and wildcards

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky http://charts.mrsharky.com
$ helm install my-release mrsharky/fooocus_extend
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
helm upgrade --install fooocus_extend . -f values.yaml --wait --timeout 5m --atomic
```

Uninstall

```bash
helm delete fooocus_extend
```

## Packaging
```bash
helm package fooocus_extend
helm repo index . --url https://charts.mrsharky.com
```

## Source Code

* <https://github.com/shaitanzx/Fooocus_extend>
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
| affinity | object | `{}` | Optional affinity overrides. |
| containerSecurityContext | object | `{}` | Optional container-level security context overrides. Leave empty unless you need to set capabilities, readOnlyRootFilesystem, seccompProfile, or similar low-level container settings. |
| controllers | object | `{}` | Optional controller override. When left empty, the chart generates the main controller from the documented settings above. Most users should leave this empty and configure the workload through the higher-level values in this file so the generated README remains accurate. |
| defaultPodOptions | object | `{}` | Optional default pod options override. When left empty, the chart creates pod defaults from the documented values above. Advanced users can override this if they need to bypass the chart's default fsGroup behavior entirely. |
| fooocusExtend.cmdArgs | string | `"--listen"` | Arguments passed to `python launch.py`. The default `--listen` matches the upstream container's remote-access behavior. |
| fooocusExtend.gid | string | `"1000"` | The GID that should own writable mounted paths inside the container. The chart also exposes pod-level security context controls, which are the primary ownership mechanism for Kubernetes. |
| fooocusExtend.port | int | `7865` | Main Fooocus_extend web port exposed by the container. |
| fooocusExtend.replicas | int | `1` | Replica count for the main deployment. Keep this at 1 unless you know the storage and runtime behavior works for your workload. The seeded defaults and persistent writable state are designed around a single-writer deployment model by default. |
| fooocusExtend.timezone | string | `"America/Los_Angeles"` | Optional timezone passed through to the container for log timestamps and any runtime behavior that depends on local time. |
| fooocusExtend.uid | string | `"1000"` | The UID that should own writable mounted paths inside the container. This matters most for hostPath-style storage and other bind-mounted Kubernetes volumes where you care about host-visible file ownership. |
| global | object | `{}` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the Fooocus_extend container. Leave this at `IfNotPresent` for stable nodes, or switch to `Always` if you rely on mutable tags such as `latest`. |
| image.repository | string | `"ghcr.io/dafrenchyman/fooocus_extend"` | Fooocus_extend image repository. |
| image.tag | string | `"latest"` | Fooocus_extend image tag. `latest` tracks the latest main build. |
| ingress.main.annotations | object | `{}` |  |
| ingress.main.className | string | `"nginx"` |  |
| ingress.main.enabled | bool | `false` |  |
| ingress.main.hosts[0].host | string | `"fooocus-extend.nixoskubemini.home.arpa"` |  |
| ingress.main.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.main.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.main.hosts[0].paths[0].service.identifier | string | `"main"` |  |
| ingress.main.hosts[0].paths[0].service.port | string | `"http"` |  |
| ingress.main.tls | list | `[]` |  |
| nodeSelector | object | `{}` | Optional node selector overrides. |
| persistence.models | object | `{"advancedMounts":{"main":{"app":[{"path":"/content/data/models","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/fooocus-extend/models","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Models and model-adjacent assets. This path is usually best placed on fast storage such as local NVMe. This directory is expected to contain checkpoints, LoRAs, embeddings, VAE approximations, upscale models, inpaint assets, controlnet assets, clip vision assets, and prompt expansion files under the app's normal subdirectory layout. |
| persistence.outputs | object | `{"advancedMounts":{"main":{"app":[{"path":"/content/data/outputs","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/fooocus-extend/outputs","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Generated images and related output artifacts. This path can usually use slower capacity-oriented storage than the model assets. Keep this separate from `models` if you want to place outputs on a larger but slower storage class. |
| persistence.runtime-state | object | `{"advancedMounts":{"main":{"app":[{"path":"/content/data/state","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/fooocus-extend/state","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Smaller runtime state including config, presets, styles, and wildcards. The container seeds baked defaults into this volume only when files are missing, so existing user customizations survive pod recreation and image upgrades. |
| podSecurityContext.fsGroup | int | `1000` | Apply a filesystem group so mounted volumes are writable by the runtime group even when the storage backend preserves ownership metadata. |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` | Only recurse ownership changes when Kubernetes detects a root mismatch. This reduces avoidable startup churn on large persistent volumes. |
| resources.limits."nvidia.com/gpu" | int | `1` |  |
| resources.requests | object | `{"cpu":"500m","memory":"4Gi"}` | GPU-enabled AI workloads can be memory hungry. Adjust CPU, memory, and GPU requests to match your node capacity and scheduling requirements. The default GPU limit assumes an NVIDIA device plugin is installed and that this workload should reserve one GPU. No memory limit is set by default because model loads and swaps can temporarily spike usage. |
| service.main.controller | string | `"main"` |  |
| service.main.enabled | bool | `true` |  |
| service.main.ports.http.port | int | `7865` |  |
| service.main.ports.http.protocol | string | `"TCP"` |  |
| service.main.ports.http.targetPort | string | `"web"` |  |
| service.main.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` | Optional toleration overrides. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
