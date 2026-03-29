# cooklang

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.26.0](https://img.shields.io/badge/AppVersion-0.26.0-informational?style=flat-square)

Cooklang recipe server powered by CookCLI

**Homepage:** <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/cooklang>

## Additional Information

Chart uses the awesome common library from [bjw-s-labs](https://bjw-s-labs.github.io/helm-charts/)

This chart deploys the upstream Cooklang CookCLI server. Enable `persistence.recipes` and point it at a directory containing your `.cook` recipes.

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky https://charts.mrsharky.com
$ helm install my-release mrsharky/cooklang
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
helm upgrade --install cooklang . -f values.yaml --wait --timeout 5m --atomic
```

Uninstall

```bash
helm delete cooklang
```

## Packaging
```bash
helm package cooklang
helm repo index . --url https://charts.mrsharky.com
```

## Source Code

* <https://cooklang.org/blog/21-self-hosting-recipes-with-docker/>
* <https://github.com/cooklang/cookcli>
* <https://bjw-s-labs.github.io/helm-charts/>

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://bjw-s-labs.github.io/helm-charts/ | common | 4.3.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controllers.main.containers.app.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the main Cooklang container. |
| controllers.main.containers.app.image.repository | string | `"ghcr.io/cooklang/cookcli"` | Upstream Cooklang server image repository. |
| controllers.main.containers.app.image.tag | string | `"0.26.0"` | Upstream image tag pinned to the latest verified GitHub release for CookCLI as of March 22, 2026. |
| controllers.main.containers.app.ports[0].containerPort | int | `9080` | Main HTTP port exposed by the Cooklang server. |
| controllers.main.containers.app.ports[0].name | string | `"web"` |  |
| controllers.main.containers.app.ports[0].protocol | string | `"TCP"` |  |
| controllers.main.replicas | int | `1` | Keep a single replica unless you have shared storage and have validated the image behavior for your environment. |
| controllers.main.strategy | string | `"Recreate"` | Recreate avoids two Pods briefly sharing the same writable recipes volume during upgrades. |
| controllers.main.type | string | `"deployment"` | Deploy Cooklang as a Deployment rather than a StatefulSet or CronJob. |
| ingress.main.annotations | object | `{}` | Optional ingress annotations for cert-manager, auth, rewrites, etc. |
| ingress.main.className | string | `"nginx"` | IngressClass to use when ingress is enabled. |
| ingress.main.enabled | bool | `false` | Enable an ingress if you want Cooklang reachable via a hostname. |
| ingress.main.hosts[0].host | string | `"cooklang"` |  |
| ingress.main.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.main.hosts[0].paths[0].pathType | string | `"Prefix"` | Prefix routing works well for the Cooklang UI. |
| ingress.main.hosts[0].paths[0].service.identifier | string | `"main"` | Send ingress traffic to the main Service. |
| ingress.main.hosts[0].paths[0].service.port | string | `"http"` | Use the HTTP service port defined above. |
| ingress.main.tls | list | `[]` | Optional TLS entries for HTTPS-enabled ingress setups. |
| persistence.recipes.accessMode | string | `"ReadWriteOnce"` | Access mode for the generated PVC when `type=persistentVolumeClaim`. |
| persistence.recipes.enabled | bool | `false` | Enable a volume for your `.cook` recipe files. Without this, the server starts but has no recipe collection to serve. |
| persistence.recipes.mountPath | string | `"/recipes"` | Mount path expected by the upstream Cooklang image. |
| persistence.recipes.size | string | `"1Gi"` | Requested PVC size for the recipes volume. Plain text recipes are small, so the default can stay modest. |
| persistence.recipes.type | string | `"persistentVolumeClaim"` | Default to a PVC-managed volume. Advanced users can switch this to `existingClaim`, `hostPath`, or another bjw-s-supported type. |
| service.main.controller | string | `"main"` | Route traffic to the `main` controller. |
| service.main.enabled | bool | `true` | Create a Service for the main Cooklang web application. |
| service.main.ports.http.port | int | `9080` | Service port for the Cooklang web UI. |
| service.main.ports.http.protocol | string | `"TCP"` |  |
| service.main.ports.http.targetPort | string | `"web"` | Target the named `web` port on the container. |
| service.main.type | string | `"ClusterIP"` | Use ClusterIP by default; enable ingress or another exposure method separately if you want browser access outside the cluster. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
