# bluecherry

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Bluecherry DVR

**Homepage:** <https://www.bluecherrydvr.com/>

## Additional Information

Chart uses the awesome common library from [k8s@home](https://github.com/k8s-at-home)

## Installing Chart from repo

To install the chart with the release name `my-release`:

```console
$ helm repo add mrsharky http://charts.mrsharky.com
$ helm install my-release mrsharky/bluecherry
```

## Installing Chart from source

Get the dependencies

```bash
helm dependency update
```

Install

```bash
helm install bluecherry .
```

Upgrade

```bash
helm upgrade bluecherry .
```

Uninstall

```bash
helm delete bluecherry
```

## Packaging
```bash
helm package bluecherry
helm repo index . --url https://charts.mrsharky.com
```

## Source Code

* <https://github.com/dafrenchyman/dockers_and_helm/tree/master/charts/bluecherry>
* <https://github.com/dafrenchyman/dockers_and_helm/tree/master/containers/bluecherry-server>
* <https://github.com/bluecherrydvr/bluecherry-docker>
* <https://hub.docker.com/r/dafrenchyman/bluecherry-server>

## Requirements

Kubernetes: `>=1.16.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://library-charts.k8s-at-home.com | common | 4.2.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bluecherry.gid | string | `"1000"` | GID to run bluecherry user as. If you want to access recordings from the host, it is recommended to set them the same as a user/group that you want access to read it. run `id $(whoami)` to find the UID/GID of your user |
| bluecherry.image.pullPolicy | string | `"Always"` | bluecherryServer image pull policy |
| bluecherry.image.repository | string | `"dafrenchyman/bluecherry-server"` | bluecherryServer image repository |
| bluecherry.image.tag | string | `"latest"` | bluecherryServer image tag |
| bluecherry.timezone | string | `"America/Los_Angeles"` | bluecherryServer image timezone |
| bluecherry.uid | string | `"1000"` | UID to run bluecherry user as. If you want to access recordings from the host, it is recommended to set them the same as a user/group that you want access to read it. run `id $(whoami)` to find the UID/GID of your user |
| bluecherry.vaapi.enabled | bool | `true` | bluecherryServer enable if you have a supported VAAPI device and /dev/dri exists on the host system. |
| ingress.main | object | See values.yaml | Enable and configure ingress settings for the chart under this key. |
| mkrecordingsdirs.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| mkrecordingsdirs.image.repository | string | `"busybox"` | image repository |
| mkrecordingsdirs.image.tag | string | `"1.34.0"` | image tag |
| mysql.admin.password | string | `"changeMe"` | MySQL admin password |
| mysql.admin.user | string | `"root"` | MySQL admin user |
| mysql.db | string | `"bluecherry"` | MySQL Database name for the bluecherry database |
| mysql.host | string | `"changeMe"` | MySQL host |
| mysql.useExisting | bool | `true` | Use an existing MySQL server |
| mysql.user.password | string | `"changeMe"` | MySQL bluecherry password |
| mysql.user.user | string | `"bluecherry"` | MySQL bluecherry user to create/use |
| mysql.userhost | string | `"%"` | MySQL bluecherry user at this hostmask. This should be the IP of your bluecherry container |
| persistence | object | See values.yaml | Configure persistence settings for the chart under this key. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)