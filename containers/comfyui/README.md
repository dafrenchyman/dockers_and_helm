# ComfyUI container

This image provides a repo-owned ComfyUI package with pinned upstream inputs and a stable runtime contract.

## Baked into the image

- ComfyUI `v0.18.0`
- ComfyUI-Manager `f4fa394` (`3.39.2`)
- ComfyUI-Sentinel `0d57d47`
- pinned CUDA-enabled PyTorch runtime dependencies from `requirements.base.txt`
- repo-managed additional dependencies from `requirements.extra.txt`

## Runtime behavior

The container startup is intentionally minimal:

- create expected runtime directories
- apply `PUID` and `PGID` ownership to writable paths
- render ComfyUI-Sentinel configuration
- start ComfyUI

The entrypoint does not install packages, clone repositories, or fetch application code from the internet.

## Runtime paths

- `/opt/comfyui/models`: model storage
- `/opt/comfyui/input`: ComfyUI input files
- `/opt/comfyui/output`: ComfyUI output files
- `/opt/comfyui/custom_nodes`: mutable custom nodes installed at runtime, plus symlinks to baked-in Manager and Sentinel
- `/opt/comfyui/baked_custom_nodes`: image-baked custom node source directories
- `/opt/comfyui/state/sentinel`: ComfyUI-Sentinel state
- `/opt/comfyui/user`: ComfyUI user directory

At startup, the container copies the baked-in `ComfyUI-Manager` and `ComfyUI-Sentinel` directories into `/opt/comfyui/custom_nodes`. Manager is copied into the runtime path as `custom_nodes/comfyui-manager`, matching the upstream installation requirement.

## Environment variables

- `PUID`: UID used for writable runtime paths. Default `1000`.
- `PGID`: GID used for writable runtime paths. Default `1000`.
- `COMFYUI_HOST`: listen address. Default `0.0.0.0`.
- `COMFYUI_PORT`: listen port. Default `8188`.
- `COMFYUI_EXTRA_ARGS`: extra arguments appended to `python main.py`.
- `COMFYUI_TEMP_DIR`: writable ComfyUI temp path. Default `/opt/comfyui/user/temp`.
- `COMFYUI_DB_PATH`: ComfyUI SQLite database path. Default `/tmp/comfyui-runtime.db`.
- `COMFYUI_RESET_DB_ON_START`: remove ComfyUI SQLite database artifacts before startup to work around current upstream locking issues. Default `true`.
- `SECRET_KEY`: optional ComfyUI-Sentinel signing secret.
- `SENTINEL_SECRET_ENV`: env var name ComfyUI-Sentinel should read for its signing secret. Default `SECRET_KEY`.
- `SENTINEL_MANAGER_ADMIN_ONLY`: whether only Sentinel admins may use ComfyUI-Manager. Default `true`.
- `SENTINEL_SEPARATE_USERS`: whether Sentinel should isolate generated outputs per user. Default `true`.
- `COMFYUI_MANAGER_NETWORK_MODE`: Manager network mode. Default `public`. Set to `offline` to avoid startup fetches.
- `COMFYUI_MANAGER_USE_UV`: whether Manager should use `uv` for pip operations. Default `False`.

## Notes

- This image targets NVIDIA GPU usage.
- Models are intentionally not baked into the image.
- Runtime-installed models and custom nodes are mutable state and should be mounted on persistent storage.
- ComfyUI-Sentinel's `separate_users` support is only partial. It helps with input/temp paths, queue history, and filename prefix handling, but it does not provide full asset isolation in a shared ComfyUI instance.
