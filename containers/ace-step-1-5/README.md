# ACE-Step 1.5 container

This image provides a repo-owned [ACE-Step 1.5](https://github.com/ace-step/ACE-Step-1.5) package with pinned upstream inputs, CUDA-oriented build-time dependency resolution, and a stable runtime contract for both Docker Compose and Helm.

## Baked into the image

- `ace-step/ACE-Step-1.5` pinned to `eddb621`
- runtime dependencies resolved during image build with `uv sync --no-dev`
- a repo-owned entrypoint that prepares persistent storage, redirects caches, and launches the Gradio web UI

## Runtime behavior

The container startup is intentionally limited to local filesystem initialization:

- create expected runtime directories
- apply `PUID` and `PGID` ownership to writable paths
- redirect model and downloader caches into persistent runtime state
- symlink application paths to persistent model, input, output, and log storage
- start the ACE-Step 1.5 Gradio web UI

The entrypoint does not install packages, run `uv sync`, or mutate the repository checkout from the network.

## Runtime paths

- `/opt/ace-step/app`: application tree with the built virtual environment
- `/opt/ace-step/data/models`: persistent model and checkpoint storage
- `/opt/ace-step/data/inputs`: persistent user-provided input/reference material
- `/opt/ace-step/data/outputs`: persistent generated output storage
- `/opt/ace-step/data/state/config`: small persistent configuration state
- `/opt/ace-step/data/state/cache`: downloader and library caches redirected from implicit home-directory defaults
- `/opt/ace-step/data/state/logs`: runtime log storage
- `/opt/ace-step/data/state/tmp`: runtime temporary files

`/opt/ace-step/app/checkpoints`, `/opt/ace-step/app/inputs`, `/opt/ace-step/app/outputs`, and `/opt/ace-step/app/logs` are symlinked into the persistent paths above at startup.

## Environment variables

- `PUID`: UID used for writable runtime paths. Default `1000`.
- `PGID`: GID used for writable runtime paths. Default `1000`.
- `PORT`: ACE-Step 1.5 web port. Default `7860`.
- `SERVER_NAME`: bind address for the Gradio web UI. Default `0.0.0.0`.
- `LANGUAGE`: UI language. Default `en`.
- `ACESTEP_CONFIG_PATH`: default DiT model selection. Default `acestep-v15-turbo`.
- `ACESTEP_LM_MODEL_PATH`: default LM selection. Default `acestep-5Hz-lm-1.7B`.
- `ACESTEP_DEVICE`: device target forwarded to ACE-Step. Default `cuda`.
- `ACESTEP_LM_BACKEND`: LM backend forwarded to ACE-Step. Default `pt`.
- `ACESTEP_INIT_LLM`: LLM initialization mode. Default `auto`.
- `ACESTEP_DOWNLOAD_SOURCE`: preferred model download source. Default `auto`.
- `ACESTEP_NO_INIT`: whether to skip eager model initialization during startup. Default `true` so ACE-Step follows its newer on-demand initialization flow.
- `ACESTEP_BATCH_SIZE`: optional batch size passed to the Gradio launcher.
- `ACESTEP_OFFLOAD_TO_CPU`: optional offload mode passed to the Gradio launcher.
- `ACESTEP_ENABLE_API`: enables upstream API endpoints alongside Gradio when set to `true`.
- `ACESTEP_API_KEY`: optional API key passed through when API support is enabled.
- `ACESTEP_AUTH_USERNAME`: optional Gradio authentication username.
- `ACESTEP_AUTH_PASSWORD`: optional Gradio authentication password.
- `ACESTEP_EXTRA_ARGS`: additional CLI arguments appended to the Gradio launch command.
- `MODELS_DIR`: model storage root. Default `/opt/ace-step/data/models`.
- `INPUTS_DIR`: user-provided inputs root. Default `/opt/ace-step/data/inputs`.
- `OUTPUTS_DIR`: generated outputs root. Default `/opt/ace-step/data/outputs`.
- `RUNTIME_STATE_DIR`: smaller runtime state root. Default `/opt/ace-step/data/state`.

The entrypoint also exports cache-related variables such as `HF_HOME`, `MODELSCOPE_CACHE`, `XDG_CACHE_HOME`, `TMPDIR`, and `GRADIO_TEMP_DIR` into the runtime-state storage tree unless they are already set.

## Notes

- This image targets NVIDIA GPU usage.
- Model assets are intentionally not baked into the image.
- The Gradio web UI is the primary supported entrypoint.
- The default runtime profile follows ACE-Step's newer on-demand initialization flow while still using the safer `pt` LM backend by default.
- API features remain an upstream concern and are not exposed as separate ports by default in this package.
