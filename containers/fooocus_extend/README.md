# Fooocus_extend container

This image provides a repo-owned [Fooocus_extend](https://github.com/shaitanzx/Fooocus_extend) package with pinned upstream inputs, seeded repo-managed defaults, and a stable runtime contract for both Docker Compose and Helm.

## Baked into the image

- `shaitanzx/Fooocus_extend` pinned to `67c346a74bb5bbdce1e84f37e0bc77d22a0ae456`
- upstream Docker runtime dependencies from `requirements_docker.txt` and `requirements_versions.txt`
- repo-managed preset defaults from `presets/`
- repo-managed style defaults from `style/`
- repo-managed wildcard defaults from `wildcards/`

## Runtime behavior

The container startup is intentionally limited to local filesystem initialization:

- create expected runtime directories
- apply `PUID` and `PGID` ownership to writable paths
- seed missing presets, styles, and wildcards into persistent storage
- seed the upstream baked model skeleton into persistent model storage
- symlink application paths to persistent runtime storage
- start `Fooocus_extend`

The entrypoint does not install packages or clone application code from the network.

## Runtime paths

- `/content/app`: application tree
- `/content/data/models`: fast persistent model storage
- `/content/data/outputs`: persistent generated outputs
- `/content/data/state/config`: small persistent configuration state
- `/content/data/state/presets`: persistent presets seeded from baked defaults
- `/content/data/state/sdxl_styles`: persistent styles seeded from baked defaults
- `/content/data/state/wildcards`: persistent wildcards seeded from baked defaults

`/content/app/models`, `/content/app/outputs`, `/content/app/presets`, `/content/app/sdxl_styles`, and `/content/app/wildcards` are symlinked into the persistent paths above at startup.

## Environment variables

- `PUID`: UID used for writable runtime paths. Default `1000`.
- `PGID`: GID used for writable runtime paths. Default `1000`.
- `CMDARGS`: extra arguments passed to `python launch.py`. Default `--listen`.
- `DATADIR`: persistent runtime root. Default `/content/data`.
- `MODELS_DIR`: model asset root. Default `/content/data/models`.
- `OUTPUTS_DIR`: generated output root. Default `/content/data/outputs`.
- `RUNTIME_STATE_DIR`: small runtime state root. Default `/content/data/state`.
- `CONFIG_DIR`: config directory. Default `/content/data/state/config`.
- `PRESETS_DIR`: preset directory. Default `/content/data/state/presets`.
- `STYLES_DIR`: style directory. Default `/content/data/state/sdxl_styles`.
- `WILDCARDS_DIR`: wildcard directory. Default `/content/data/state/wildcards`.

The container also exports default `Fooocus_extend` path variables for checkpoints, LoRAs, embeddings, VAE approximations, upscale models, inpaint, controlnet, clip vision, prompt expansion, and outputs.

## Notes

- This image targets NVIDIA GPU usage.
- Model assets are intentionally not baked into the image.
- The baked preset/style/wildcard defaults are copied into persistent storage only when the target files are missing.
- Existing runtime files are preserved across restarts and upgrades.
