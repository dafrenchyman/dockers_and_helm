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
| [`turbowarp`](./turbowarp/)                                                     |          `a2946ee` |       `0.1.0` | TurboWarp Scratch-compatible editor for local self-hosting.             |
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

Published chart packages are released through the GitHub Actions workflow in
[`../.github/workflows/helm-charts-release.yml`](../.github/workflows/helm-charts-release.yml).
The canonical chart repository URL is:

```text
https://charts.mrsharky.com/
```

The workflow:

- runs when chart versions change in `charts/*/Chart.yaml`
- packages only charts whose changed `Chart.yaml` declares a new chart version
- uploads chart `.tgz` packages to GitHub Releases
- generates `index.yaml` with package URLs that point to GitHub Release assets
- assembles the static landing page, `index.yaml`, and Artifact Hub metadata into one deployable artifact
- deploys that artifact to GitHub Pages first and the SFTP-backed `charts.mrsharky.com` host second

### Release policy

Chart releases are version-bump driven. Change chart templates, values, or
documentation freely in pull requests, but publish a chart by bumping that
chart's `version` in `Chart.yaml`.

### Artifact Hub

Artifact Hub should be configured with the canonical Helm repository URL:

```text
https://charts.mrsharky.com/
```

The publishing workflow serves `artifacthub-repo.yml` beside `index.yaml` so
Artifact Hub can claim and index the repository from the same HTTP path.
