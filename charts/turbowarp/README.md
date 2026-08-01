# turbowarp

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: a2946ee](https://img.shields.io/badge/AppVersion-a2946ee-informational?style=flat-square)

TurboWarp Scratch-compatible editor for local self-hosting

**Homepage:** <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/turbowarp>

## Additional Information

Chart uses the awesome common library from [bjw-s-labs](https://bjw-s-labs.github.io/helm-charts/)

This chart deploys the TurboWarp GUI/editor from a repo-owned static web image using the LinuxServer.io nginx runtime, so Scratch-compatible projects can be created locally without using Scratch's website. The chart exposes LinuxServer-style PUID/PGID/TZ/UMASK settings; no persistent volume is required for the TurboWarp GUI itself.

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky https://charts.mrsharky.com/
$ helm install my-release mrsharky/turbowarp
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
helm upgrade --install turbowarp . -f values.yaml --wait --timeout 5m --atomic
```

Uninstall

```bash
helm delete turbowarp
```

## Packaging
```bash
helm package turbowarp
helm repo index . --url https://charts.mrsharky.com/
```

## Source Code

* <https://github.com/TurboWarp/scratch-gui>
* <https://docs.turbowarp.org/development/getting-started>
* <https://docs.linuxserver.io/images/docker-nginx/>
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
| controllers.main.containers.app.env[0] | object | `{"name":"PUID","value":"{{ .Values.turbowarp.puid }}"}` | LinuxServer.io runtime UID for writable `/config` files when optional persistence is enabled. |
| controllers.main.containers.app.env[1] | object | `{"name":"PGID","value":"{{ .Values.turbowarp.pgid }}"}` | LinuxServer.io runtime GID for writable `/config` files when optional persistence is enabled. |
| controllers.main.containers.app.env[2] | object | `{"name":"TZ","value":"{{ .Values.turbowarp.timezone }}"}` | LinuxServer.io runtime timezone. |
| controllers.main.containers.app.env[3] | object | `{"name":"UMASK","value":"{{ .Values.turbowarp.umask }}"}` | LinuxServer.io file creation mask. |
| controllers.main.containers.app.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the TurboWarp web container. |
| controllers.main.containers.app.image.repository | string | `"ghcr.io/dafrenchyman/turbowarp"` | Repo-owned TurboWarp static web image repository. |
| controllers.main.containers.app.image.tag | string | `"upstream-a2946ee"` | Image tag pinned to the verified TurboWarp scratch-gui commit `a2946ee`. |
| controllers.main.containers.app.ports[0] | object | `{"containerPort":80,"name":"web","protocol":"TCP"}` | Main HTTP port exposed by the TurboWarp nginx container. |
| controllers.main.containers.app.probes.liveness.custom | bool | `true` | Use a fully custom Kubernetes liveness probe spec so the check is exactly HTTP `/` on the named `web` port. |
| controllers.main.containers.app.probes.liveness.enabled | bool | `true` | Enable liveness probe against the static GUI root to restart nginx if it stops serving. |
| controllers.main.containers.app.probes.liveness.spec | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"web"},"initialDelaySeconds":30,"periodSeconds":30}` | Kubernetes liveness probe fields rendered under `livenessProbe`. |
| controllers.main.containers.app.probes.liveness.spec.failureThreshold | int | `3` | Liveness probe failure threshold. |
| controllers.main.containers.app.probes.liveness.spec.httpGet | object | `{"path":"/","port":"web"}` | HTTP check used by the liveness probe. |
| controllers.main.containers.app.probes.liveness.spec.httpGet.path | string | `"/"` | HTTP path used by the liveness probe. |
| controllers.main.containers.app.probes.liveness.spec.httpGet.port | string | `"web"` | Named container port used by the liveness probe. |
| controllers.main.containers.app.probes.liveness.spec.initialDelaySeconds | int | `30` | Liveness probe initial delay in seconds. |
| controllers.main.containers.app.probes.liveness.spec.periodSeconds | int | `30` | Liveness probe interval in seconds. |
| controllers.main.containers.app.probes.readiness.custom | bool | `true` | Use a fully custom Kubernetes readiness probe spec so the check is exactly HTTP `/` on the named `web` port. |
| controllers.main.containers.app.probes.readiness.enabled | bool | `true` | Enable readiness probe against the static GUI root so traffic only reaches ready nginx Pods. |
| controllers.main.containers.app.probes.readiness.spec | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"web"},"initialDelaySeconds":10,"periodSeconds":10}` | Kubernetes readiness probe fields rendered under `readinessProbe`. |
| controllers.main.containers.app.probes.readiness.spec.failureThreshold | int | `3` | Readiness probe failure threshold. |
| controllers.main.containers.app.probes.readiness.spec.httpGet | object | `{"path":"/","port":"web"}` | HTTP check used by the readiness probe. |
| controllers.main.containers.app.probes.readiness.spec.httpGet.path | string | `"/"` | HTTP path used by the readiness probe. |
| controllers.main.containers.app.probes.readiness.spec.httpGet.port | string | `"web"` | Named container port used by the readiness probe. |
| controllers.main.containers.app.probes.readiness.spec.initialDelaySeconds | int | `10` | Readiness probe initial delay in seconds. |
| controllers.main.containers.app.probes.readiness.spec.periodSeconds | int | `10` | Readiness probe interval in seconds. |
| controllers.main.containers.app.probes.startup.custom | bool | `true` | Use a fully custom Kubernetes startup probe spec so the check is exactly HTTP `/` on the named `web` port. |
| controllers.main.containers.app.probes.startup.enabled | bool | `true` | Enable startup probe against the static GUI root before liveness checks begin. |
| controllers.main.containers.app.probes.startup.spec | object | `{"failureThreshold":18,"httpGet":{"path":"/","port":"web"},"initialDelaySeconds":10,"periodSeconds":5}` | Kubernetes startup probe fields rendered under `startupProbe`. |
| controllers.main.containers.app.probes.startup.spec.failureThreshold | int | `18` | Startup probe failure threshold; allows up to 90 seconds after the initial delay. |
| controllers.main.containers.app.probes.startup.spec.httpGet | object | `{"path":"/","port":"web"}` | HTTP check used by the startup probe. |
| controllers.main.containers.app.probes.startup.spec.httpGet.path | string | `"/"` | HTTP path used by the startup probe. |
| controllers.main.containers.app.probes.startup.spec.httpGet.port | string | `"web"` | Named container port used by the startup probe. |
| controllers.main.containers.app.probes.startup.spec.initialDelaySeconds | int | `10` | Startup probe initial delay in seconds. |
| controllers.main.containers.app.probes.startup.spec.periodSeconds | int | `5` | Startup probe interval in seconds. |
| controllers.main.replicas | int | `1` | Number of TurboWarp web Pods. One replica is enough for home/local use and avoids unnecessary duplicate static servers. |
| controllers.main.strategy | string | `"RollingUpdate"` | Rolling updates are safe because the image serves static files and has no required shared project volume. |
| controllers.main.type | string | `"deployment"` | Deploy TurboWarp as a Deployment because the GUI is static and does not require stable Pod identity. |
| global | object | `{}` | Global bjw-s common values. Leave empty unless you need common-library-wide overrides such as name overrides. |
| ingress.main.annotations | object | `{}` | Optional ingress annotations for cert-manager, auth, rewrites, etc. |
| ingress.main.className | string | `"nginx"` | IngressClass to use when ingress is enabled. |
| ingress.main.enabled | bool | `false` | Enable ingress if you want TurboWarp reachable via a hostname. |
| ingress.main.hosts[0] | object | `{"host":"turbowarp","paths":[{"path":"/","pathType":"Prefix","service":{"identifier":"main","port":"http"}}]}` | Host rules for the TurboWarp ingress. |
| ingress.main.hosts[0].paths[0].pathType | string | `"Prefix"` | Prefix routing sends all editor paths to the TurboWarp Service. |
| ingress.main.hosts[0].paths[0].service.identifier | string | `"main"` | Send ingress traffic to the main Service. |
| ingress.main.hosts[0].paths[0].service.port | string | `"http"` | Use the HTTP service port defined above. |
| ingress.main.tls | list | `[]` | Optional TLS entries for HTTPS-enabled ingress setups. |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode for the generated `/config` PVC when enabled. |
| persistence.config.advancedMounts.main.app[0] | object | `{"path":"/config"}` | Mount path used by LinuxServer.io nginx for web files, site config, and logs. |
| persistence.config.enabled | bool | `false` | Enable only if you want to persist LinuxServer.io nginx config, logs, and copied static-file state. This is not Scratch project persistence and is not required for the TurboWarp GUI itself. |
| persistence.config.size | string | `"1Gi"` | Requested PVC size for nginx config, logs, and copied static files. |
| persistence.config.type | string | `"persistentVolumeClaim"` | Default to a PVC-managed `/config` volume. Advanced users can switch this to another bjw-s-supported persistence type. |
| service.main.controller | string | `"main"` | Route traffic to the `main` controller. |
| service.main.enabled | bool | `true` | Create a Service for the TurboWarp web application. |
| service.main.ports.http.port | int | `80` | Service port for the TurboWarp editor. |
| service.main.ports.http.protocol | string | `"TCP"` | Service port protocol for the TurboWarp editor. |
| service.main.ports.http.targetPort | string | `"web"` | Target the named `web` port on the container. |
| service.main.type | string | `"ClusterIP"` | Use ClusterIP by default; enable ingress or another exposure method separately for browser access outside the cluster. |
| turbowarp.pgid | string | `"1000"` | Group ID passed as `PGID`; useful when optional `/config` persistence is backed by host-owned storage. |
| turbowarp.puid | string | `"1000"` | User ID passed as `PUID`; useful when optional `/config` persistence is backed by host-owned storage. |
| turbowarp.timezone | string | `"Etc/UTC"` | Timezone passed to the LinuxServer.io nginx runtime as `TZ`. |
| turbowarp.umask | string | `"022"` | File creation mask passed as `UMASK` for LinuxServer.io runtime-managed files. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
