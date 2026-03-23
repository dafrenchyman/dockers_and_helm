# Helm Charts

## Add this chart repo

To make the published charts in this repository available to Helm:

```bash
helm repo add mrsharky https://charts.mrsharky.com/
helm repo update
```

## Available charts

The following charts are currently committed in this repository:

- `ambient-weather-prometheus-exporter`
- `bluecherry`
- `comfyui`
- `kavita`
- `nzbget-exporter`
- `ps3netsrv`
- `termix`
- `ubooquity`

# Instructions for publishing charts

## For each of the chart repos:

- `helm dependency update` - Updates the dependencies (and a lock file if present)
- `helm dependency build .` - Builds the dependencies
- `helm package .`
- Move all the `*.tgz` into a common folder

## To generate the `index.yaml`

- In the common folder where all the `*.tgz have been moved`
  - `helm repo index . --url https://charts.mrsharky.com/`

## Scriptable flow

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

rm -rf "$OUTPUT_DIR"
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


cp "$OUTPUT_DIR"/*.tgz "$CHARTS_DIR"/
helm repo index "$CHARTS_DIR" --url https://charts.mrsharky.com/
```
