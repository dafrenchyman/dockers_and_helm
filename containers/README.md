# Docker Containers

This directory contains the Docker container build contexts committed to this repository. Each catalog entry below has committed container source, not just a working-tree directory.

## Committed containers

Only directories with committed Dockerfile content are listed here.

| Container                             | Build context                                                                    | Description                                                                                                                                  |
| ------------------------------------- | -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `ace-step-1-5`                        | [`ace-step-1-5/`](./ace-step-1-5/)                                               | Repo-owned ACE-Step 1.5 Gradio image with pinned upstream inputs, CUDA-oriented dependencies, and persistent model/input/output/state paths. |
| `ambient-weather-prometheus-exporter` | [`ambient-weather-prometheus-exporter/`](./ambient-weather-prometheus-exporter/) | Python Prometheus exporter for Ambient Weather station metrics.                                                                              |
| `bluecherry-server`                   | [`bluecherry-server/`](./bluecherry-server/)                                     | Bluecherry server image variant that allows runtime UID/GID assignment.                                                                      |
| `comfyui`                             | [`comfyui/`](./comfyui/)                                                         | Repo-owned ComfyUI image with pinned ComfyUI, baked ComfyUI-Manager, baked ComfyUI-Sentinel, and stable runtime paths.                       |
| `fooocus_extend`                      | [`fooocus_extend/`](./fooocus_extend/)                                           | Repo-owned Fooocus_extend image with pinned upstream code and seeded presets, styles, and wildcards.                                         |
| `turbowarp`                           | [`turbowarp/`](./turbowarp/)                                                     | Pinned TurboWarp GUI static web image served by LinuxServer.io nginx for local Scratch-compatible editing.                                   |
| `paddleocr-vl-hps`                    | [`paddleocr-vl-hps/`](./paddleocr-vl-hps/)                                       | Generic PaddleOCR-VL gateway and pipeline images used by the `charts/paddleocr-vl` Helm chart.                                               |

## Container README automation

There is not currently a container README generator configured in this repository. The closest Dockerfile-focused tool found during research is [`dock-docs`](https://github.com/northcutted/dock-docs), which can generate Markdown documentation from Dockerfiles and image inspection. It may be worth evaluating later if the container READMEs become too repetitive to maintain by hand.

## Notes for maintainers

- Keep container-specific runtime contracts, environment variables, build commands, and compose examples in each container directory's README.
- Keep this file as the committed-container catalog only.
- Do not add uncommitted work-in-progress directories to this catalog until their Dockerfile content is committed.
