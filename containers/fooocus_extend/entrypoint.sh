#!/bin/sh

set -eu

APP_HOME="${APP_HOME:-/content/app}"
DATA_ROOT="${DATADIR:-${DATA_ROOT:-/content/data}}"
MODELS_DIR="${MODELS_DIR:-${DATA_ROOT}/models}"
OUTPUTS_DIR="${OUTPUTS_DIR:-${DATA_ROOT}/outputs}"
RUNTIME_STATE_DIR="${RUNTIME_STATE_DIR:-${DATA_ROOT}/state}"
CONFIG_DIR="${CONFIG_DIR:-${RUNTIME_STATE_DIR}/config}"
PRESETS_DIR="${PRESETS_DIR:-${RUNTIME_STATE_DIR}/presets}"
STYLES_DIR="${STYLES_DIR:-${RUNTIME_STATE_DIR}/sdxl_styles}"
WILDCARDS_DIR="${WILDCARDS_DIR:-${RUNTIME_STATE_DIR}/wildcards}"
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
CMDARGS="${CMDARGS:---listen}"

export DATADIR="${DATA_ROOT}"
export config_path="${config_path:-${CONFIG_DIR}/config.txt}"
export config_example_path="${config_example_path:-${CONFIG_DIR}/config_modification_tutorial.txt}"
export path_checkpoints="${path_checkpoints:-${MODELS_DIR}/checkpoints/}"
export path_loras="${path_loras:-${MODELS_DIR}/loras/}"
export path_embeddings="${path_embeddings:-${MODELS_DIR}/embeddings/}"
export path_vae_approx="${path_vae_approx:-${MODELS_DIR}/vae_approx/}"
export path_upscale_models="${path_upscale_models:-${MODELS_DIR}/upscale_models/}"
export path_inpaint="${path_inpaint:-${MODELS_DIR}/inpaint/}"
export path_controlnet="${path_controlnet:-${MODELS_DIR}/controlnet/}"
export path_clip_vision="${path_clip_vision:-${MODELS_DIR}/clip_vision/}"
export path_fooocus_expansion="${path_fooocus_expansion:-${MODELS_DIR}/prompt_expansion/fooocus_expansion/}"
export path_outputs="${path_outputs:-${APP_HOME}/outputs/}"

ensure_runtime_dirs() {
    mkdir -p \
        "${MODELS_DIR}/checkpoints" \
        "${MODELS_DIR}/loras" \
        "${MODELS_DIR}/embeddings" \
        "${MODELS_DIR}/vae_approx" \
        "${MODELS_DIR}/upscale_models" \
        "${MODELS_DIR}/inpaint" \
        "${MODELS_DIR}/controlnet" \
        "${MODELS_DIR}/clip_vision" \
        "${MODELS_DIR}/prompt_expansion" \
        "${OUTPUTS_DIR}" \
        "${CONFIG_DIR}" \
        "${PRESETS_DIR}" \
        "${STYLES_DIR}" \
        "${WILDCARDS_DIR}"
}

seed_dir() {
    source_dir="$1"
    target_dir="$2"

    if [ -d "${source_dir}" ]; then
        cp -Rpn "${source_dir}/." "${target_dir}/"
    fi
}

replace_with_symlink() {
    link_path="$1"
    target_path="$2"

    rm -rf "${link_path}"
    ln -s "${target_path}" "${link_path}"
}

configure_runtime_user() {
    if [ "$(id -u)" -ne 0 ]; then
        return
    fi

    if [ "$(getent group fooocus | cut -d: -f3)" != "${PGID}" ]; then
        groupmod -o -g "${PGID}" fooocus
    fi

    if [ "$(id -u fooocus)" != "${PUID}" ]; then
        usermod -o -u "${PUID}" fooocus
    fi

    chown -R "${PUID}:${PGID}" "${DATA_ROOT}" /home/fooocus
}

prepare_application_tree() {
    seed_dir "${APP_HOME}/models.org" "${MODELS_DIR}"
    seed_dir "/content/defaults/presets" "${PRESETS_DIR}"
    seed_dir "/content/defaults/sdxl_styles" "${STYLES_DIR}"
    seed_dir "/content/defaults/wildcards" "${WILDCARDS_DIR}"

    replace_with_symlink "${APP_HOME}/models" "${MODELS_DIR}"
    replace_with_symlink "${APP_HOME}/outputs" "${OUTPUTS_DIR}"
    replace_with_symlink "${APP_HOME}/presets" "${PRESETS_DIR}"
    replace_with_symlink "${APP_HOME}/sdxl_styles" "${STYLES_DIR}"
    replace_with_symlink "${APP_HOME}/wildcards" "${WILDCARDS_DIR}"
}

start_application() {
    cd "${APP_HOME}"
    set -- python launch.py ${CMDARGS}

    if [ "$(id -u)" -eq 0 ]; then
        export HOME=/home/fooocus
        exec gosu fooocus "$@"
    fi

    exec "$@"
}

ensure_runtime_dirs
prepare_application_tree
configure_runtime_user
start_application
