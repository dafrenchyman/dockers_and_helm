# comfyui

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.18.0](https://img.shields.io/badge/AppVersion-v0.18.0-informational?style=flat-square)

ComfyUI with baked ComfyUI-Manager and ComfyUI-Sentinel

**Homepage:** <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/comfyui>

## Additional Information

Chart uses the awesome common library from [bjw-s-labs](https://bjw-s-labs.github.io/helm-charts/)

ComfyUI-Sentinel's `separate_users` support is only partial. It helps with input/temp paths, queue history, and filename prefix handling, but it does not provide full asset isolation in a shared ComfyUI instance.

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky http://charts.mrsharky.com
$ helm install my-release mrsharky/comfyui
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
helm upgrade --install comfyui . -f values.yaml --wait --timeout 5m --atomic
```

Uninstall

```bash
helm delete comfyui
```

## Packaging
```bash
helm package comfyui
helm repo index . --url https://charts.mrsharky.com
```

## Source Code

* <https://github.com/comfyanonymous/ComfyUI>
* <https://github.com/Comfy-Org/ComfyUI-Manager>
* <https://github.com/LucipherDev/ComfyUI-Sentinel>
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
| comfyui.extraArgs | string | `""` | Additional arguments appended to `python main.py`. |
| comfyui.gid | string | `"1000"` | The GID that should own writable mounted paths inside the container. |
| comfyui.host | string | `"0.0.0.0"` | Listen address passed to ComfyUI. |
| comfyui.port | int | `8188` | Main ComfyUI web port exposed by the container. |
| comfyui.replicas | int | `1` | Replica count for the main deployment. Keep this at 1 unless you know the storage and runtime behavior works for your workload. |
| comfyui.timezone | string | `"America/Los_Angeles"` | Timezone passed through to the container. |
| comfyui.uid | string | `"1000"` | The UID that should own writable mounted paths inside the container. |
| controllers | object | `{}` | Optional controller override. When left empty, the chart generates the main controller from the documented settings above. |
| defaultPodOptions | object | `{}` | Optional default pod options override. The chart injects an fsGroup by default based on `comfyui.gid`, but advanced users can override it here. |
| global | object | `{}` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the ComfyUI container. |
| image.repository | string | `"ghcr.io/dafrenchyman/comfyui"` | ComfyUI image repository. |
| image.tag | string | `"sha-58cf41b"` | ComfyUI image tag. `latest` tracks the latest main build. |
| ingress.main.annotations | object | `{}` |  |
| ingress.main.className | string | `"nginx"` |  |
| ingress.main.enabled | bool | `false` |  |
| ingress.main.hosts[0].host | string | `"comfyui.nixoskubemini.home.arpa"` |  |
| ingress.main.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.main.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.main.hosts[0].paths[0].service.identifier | string | `"main"` |  |
| ingress.main.hosts[0].paths[0].service.port | string | `"http"` |  |
| ingress.main.tls | list | `[]` |  |
| nodeSelector | object | `{}` | Optional node selector overrides. |
| persistence.custom-nodes | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/comfyui/custom_nodes","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/comfyui/custom_nodes","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Mutable custom nodes installed by ComfyUI-Manager or added manually. |
| persistence.input | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/comfyui/input","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/comfyui/input","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Files uploaded to ComfyUI as inputs. |
| persistence.models | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/comfyui/models","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/comfyui/models","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Models downloaded or installed by the user. This is usually the largest and most important persistent path to keep. |
| persistence.output | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/comfyui/output","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/comfyui/output","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | Generated ComfyUI outputs. |
| persistence.sentinel-state | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/comfyui/state/sentinel","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/comfyui/sentinel","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | ComfyUI-Sentinel state, including users, lists, and log output. |
| persistence.user | object | `{"advancedMounts":{"main":{"app":[{"path":"/opt/comfyui/user","readOnly":false}]}},"enabled":true,"hostPath":"/mnt/local/kube/data/comfyui/user","hostPathType":"DirectoryOrCreate","type":"hostPath"}` | ComfyUI user directory. Keep this persistent if you want user state to survive Pod recreation. |
| resources.limits.memory | string | `"12Gi"` |  |
| resources.requests | object | `{"cpu":"500m","memory":"4Gi"}` | GPU-enabled AI workloads can be memory hungry. Adjust CPU, memory, and GPU requests to match your node capacity and desired scheduling guarantees. |
| sentinel.existingSecret | string | `""` | Existing Secret name to use for the Sentinel signing secret. When empty, the chart creates and manages a Secret for the release. |
| sentinel.generatedSecretKey | string | `""` | Optional fixed signing secret value. Leave empty to auto-generate one on first install and preserve it across upgrades. |
| sentinel.managerAdminOnly | bool | `true` | Whether ComfyUI-Manager should be admin-only under Sentinel. |
| sentinel.secretKeyKey | string | `"SECRET_KEY"` | Secret key name containing the Sentinel signing secret. |
| sentinel.secretName | string | `"comfyui-sentinel-secret"` | Secret name used when the chart manages the Sentinel signing secret. Ignored when `existingSecret` is set. |
| sentinel.separateUsers | bool | `true` | Whether Sentinel should isolate generated outputs per user. |
| service.main.controller | string | `"main"` |  |
| service.main.enabled | bool | `true` |  |
| service.main.ports.http.port | int | `8188` |  |
| service.main.ports.http.protocol | string | `"TCP"` |  |
| service.main.ports.http.targetPort | string | `"web"` |  |
| service.main.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` | Optional toleration overrides. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
