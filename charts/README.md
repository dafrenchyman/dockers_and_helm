# Helm Charts

This directory contains the Helm charts committed to this repository. Each chart owns its generated README through the existing [`helm-docs`](https://github.com/norwoodj/helm-docs) pre-commit hook and a chart-local `README.md.gotmpl` template.

## Add this chart repo

To make the published charts in this repository available to Helm:

```bash
helm repo add mrsharky https://charts.mrsharky.com/
helm repo update
```

## Committed charts

Only chart directories with a committed `Chart.yaml` are listed here.

| Chart                                                                           |        App version | Chart version | Description                                                             |
| ------------------------------------------------------------------------------- | -----------------: | ------------: | ----------------------------------------------------------------------- |
| [`ace-step-1-5`](./ace-step-1-5/)                                               |          `eddb621` |       `0.1.1` | ACE-Step 1.5 Gradio web UI with four-tier persistent storage.           |
| [`ambient-weather-prometheus-exporter`](./ambient-weather-prometheus-exporter/) |            `1.0.0` |       `0.1.0` | Prometheus metric exporter for Ambient Weather stations.                |
| [`bluecherry`](./bluecherry/)                                                   |            `1.0.0` |       `0.1.0` | Bluecherry DVR deployment.                                              |
| [`comfyui`](./comfyui/)                                                         |          `v0.18.0` |       `0.1.2` | ComfyUI with baked ComfyUI-Manager and ComfyUI-Sentinel support.        |
| [`cooklang`](./cooklang/)                                                       |           `0.26.0` |       `0.1.0` | Cooklang recipe server powered by CookCLI.                              |
| [`docling-serve`](./docling-serve/)                                             |            `1.9.0` |       `0.1.2` | Docling-Serve API wrapper for AI document conversion.                   |
| [`fooocus_extend`](./fooocus_extend/)                                           |          `67c346a` |       `0.1.1` | Fooocus_extend with repo-managed seeded presets, styles, and wildcards. |
| [`kavita`](./kavita/)                                                           |            `0.4.8` |       `0.1.0` | Fast, feature-rich manga and reading server.                            |
| [`nzbget-exporter`](./nzbget-exporter/)                                         |            `0.1.0` |       `0.1.0` | Prometheus exporter for NZBGet.                                         |
| [`paddleocr-vl`](./paddleocr-vl/)                                               | `PaddleOCR-VL-1.6` |       `0.1.0` | High-performance PaddleOCR-VL OCR and document parsing API.             |
| [`ps3netsrv`](./ps3netsrv/)                                                     |            `1.0.0` |       `0.1.0` | ps3netsrv deployment for serving PS3 game backups over the network.     |
| [`termix`](./termix/)                                                           |            `2.0.0` |       `0.1.1` | Termix SSH/server-management web application.                           |
| [`ubooquity`](./ubooquity/)                                                     |    `version-2.1.2` |       `0.1.0` | Lightweight home server for comics and ebooks.                          |

## Chart README generation

The root pre-commit configuration runs `helm-docs` with:

```text
--chart-search-root=./charts
--template-files=README.md.gotmpl
```

When chart metadata or values change, run:

```bash
pre-commit run helm-docs --all-files
```

## Publishing charts

### For each chart directory

- `helm dependency update` updates dependencies and the lock file if present.
- `helm dependency build .` builds dependencies.
- `helm package .` packages the chart.
- Move all generated `*.tgz` files into a common folder.

### Generate `index.yaml`

From the common package folder:

```bash
helm repo index . --url https://charts.mrsharky.com/
```

## Scriptable publishing flow

Run this from `charts/`:

```bash
set -euo pipefail

CHARTS_DIR="$(pwd)"
OUTPUT_DIR="$CHARTS_DIR/.packages"

ensure_repo() {
  local name="$1"
  local url="$2"

  if helm repo list | awk '{print $1}' | grep -Fxq "$name"; then
    echo "==> Helm repo '$name' already exists"
  else
    helm repo add "$name" "$url"
  fi
}

ensure_repo library-charts-k8s-at-home https://library-charts.k8s-at-home.com
ensure_repo bjw-s https://bjw-s-labs.github.io/helm-charts/
helm repo update

mkdir -p "$OUTPUT_DIR"

find "$CHARTS_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r chart_dir; do
  if [ ! -f "$chart_dir/Chart.yaml" ]; then
    continue
  fi

  echo "==> Processing $(basename "$chart_dir")"
  (
    cd "$chart_dir"
    helm dependency update
    helm dependency build .
    helm package . --destination "$OUTPUT_DIR"
  )
done

helm repo index "$OUTPUT_DIR" --url https://charts.mrsharky.com/
```
