#!/bin/sh

set -eu

APP_HOME="${APP_HOME:-/opt/ace-step/app}"
DATA_ROOT="${DATA_ROOT:-/opt/ace-step/data}"
MODELS_DIR="${MODELS_DIR:-${DATA_ROOT}/models}"
INPUTS_DIR="${INPUTS_DIR:-${DATA_ROOT}/inputs}"
OUTPUTS_DIR="${OUTPUTS_DIR:-${DATA_ROOT}/outputs}"
RUNTIME_STATE_DIR="${RUNTIME_STATE_DIR:-${DATA_ROOT}/state}"
CONFIG_DIR="${CONFIG_DIR:-${RUNTIME_STATE_DIR}/config}"
CACHE_DIR="${CACHE_DIR:-${RUNTIME_STATE_DIR}/cache}"
LOGS_DIR="${LOGS_DIR:-${RUNTIME_STATE_DIR}/logs}"
TMP_DIR="${TMP_DIR:-${RUNTIME_STATE_DIR}/tmp}"
PORT="${PORT:-7860}"
SERVER_NAME="${SERVER_NAME:-0.0.0.0}"
LANGUAGE="${LANGUAGE:-en}"
ACESTEP_CONFIG_PATH="${ACESTEP_CONFIG_PATH:-acestep-v15-turbo}"
ACESTEP_LM_MODEL_PATH="${ACESTEP_LM_MODEL_PATH:-acestep-5Hz-lm-1.7B}"
ACESTEP_DEVICE="${ACESTEP_DEVICE:-cuda}"
ACESTEP_LM_BACKEND="${ACESTEP_LM_BACKEND:-pt}"
ACESTEP_INIT_LLM="${ACESTEP_INIT_LLM:-auto}"
ACESTEP_DOWNLOAD_SOURCE="${ACESTEP_DOWNLOAD_SOURCE:-auto}"
ACESTEP_NO_INIT="${ACESTEP_NO_INIT:-true}"
ACESTEP_BATCH_SIZE="${ACESTEP_BATCH_SIZE:-}"
ACESTEP_OFFLOAD_TO_CPU="${ACESTEP_OFFLOAD_TO_CPU:-}"
ACESTEP_ENABLE_API="${ACESTEP_ENABLE_API:-false}"
ACESTEP_API_KEY="${ACESTEP_API_KEY:-}"
ACESTEP_AUTH_USERNAME="${ACESTEP_AUTH_USERNAME:-}"
ACESTEP_AUTH_PASSWORD="${ACESTEP_AUTH_PASSWORD:-}"
ACESTEP_EXTRA_ARGS="${ACESTEP_EXTRA_ARGS:-}"
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

ensure_runtime_dirs() {
    mkdir -p \
        "${MODELS_DIR}" \
        "${INPUTS_DIR}" \
        "${OUTPUTS_DIR}" \
        "${CONFIG_DIR}" \
        "${CACHE_DIR}/huggingface" \
        "${CACHE_DIR}/modelscope" \
        "${CACHE_DIR}/xdg" \
        "${LOGS_DIR}" \
        "${TMP_DIR}/gradio"
}

replace_with_symlink() {
    link_path="$1"
    target_path="$2"

    rm -rf "${link_path}"
    ln -s "${target_path}" "${link_path}"
}

prepare_application_tree() {
    replace_with_symlink "${APP_HOME}/checkpoints" "${MODELS_DIR}"
    replace_with_symlink "${APP_HOME}/inputs" "${INPUTS_DIR}"
    replace_with_symlink "${APP_HOME}/outputs" "${OUTPUTS_DIR}"
    replace_with_symlink "${APP_HOME}/gradio_outputs" "${OUTPUTS_DIR}"
    replace_with_symlink "${APP_HOME}/logs" "${LOGS_DIR}"
}

configure_runtime_user() {
    if [ "$(id -u)" -ne 0 ]; then
        return
    fi

    current_group="$(id -gn acestep)"

    if [ "$(getent group "${current_group}" | cut -d: -f3)" != "${PGID}" ]; then
        groupmod -o -g "${PGID}" "${current_group}"
    fi

    if [ "$(id -u acestep)" != "${PUID}" ]; then
        usermod -o -u "${PUID}" acestep
    fi

    chown -R "${PUID}:${PGID}" "${DATA_ROOT}" /home/acestep
    chown "${PUID}:${PGID}" "${APP_HOME}" /opt/ace-step
}

export_runtime_env() {
    export HF_HOME="${HF_HOME:-${CACHE_DIR}/huggingface}"
    export MODELSCOPE_CACHE="${MODELSCOPE_CACHE:-${CACHE_DIR}/modelscope}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${CACHE_DIR}/xdg}"
    export TMPDIR="${TMPDIR:-${TMP_DIR}}"
    export GRADIO_TEMP_DIR="${GRADIO_TEMP_DIR:-${TMP_DIR}/gradio}"
}

start_application() {
    cd "${APP_HOME}"
    export HOME="${HOME:-/home/acestep}"

    set -- \
        "${APP_HOME}/.venv/bin/acestep" \
        --server-name "${SERVER_NAME}" \
        --port "${PORT}" \
        --language "${LANGUAGE}" \
        --config_path "${ACESTEP_CONFIG_PATH}" \
        --device "${ACESTEP_DEVICE}" \
        --lm_model_path "${ACESTEP_LM_MODEL_PATH}" \
        --backend "${ACESTEP_LM_BACKEND}" \
        --init_llm "${ACESTEP_INIT_LLM}"

    if [ "${ACESTEP_NO_INIT}" = "true" ]; then
        set -- "$@" --init_service false
    else
        set -- "$@" --init_service true
    fi

    if [ "${ACESTEP_DOWNLOAD_SOURCE}" != "auto" ]; then
        set -- "$@" --download-source "${ACESTEP_DOWNLOAD_SOURCE}"
    fi

    if [ -n "${ACESTEP_BATCH_SIZE}" ]; then
        set -- "$@" --batch_size "${ACESTEP_BATCH_SIZE}"
    fi

    if [ -n "${ACESTEP_OFFLOAD_TO_CPU}" ]; then
        set -- "$@" --offload_to_cpu "${ACESTEP_OFFLOAD_TO_CPU}"
    fi

    if [ "${ACESTEP_ENABLE_API}" = "true" ]; then
        set -- "$@" --enable-api
    fi

    if [ -n "${ACESTEP_API_KEY}" ]; then
        set -- "$@" --api-key "${ACESTEP_API_KEY}"
    fi

    if [ -n "${ACESTEP_AUTH_USERNAME}" ]; then
        set -- "$@" --auth-username "${ACESTEP_AUTH_USERNAME}"
    fi

    if [ -n "${ACESTEP_AUTH_PASSWORD}" ]; then
        set -- "$@" --auth-password "${ACESTEP_AUTH_PASSWORD}"
    fi

    if [ -n "${ACESTEP_EXTRA_ARGS}" ]; then
        # shellcheck disable=SC2086
        set -- "$@" ${ACESTEP_EXTRA_ARGS}
    fi

    if [ "$(id -u)" -eq 0 ]; then
        exec gosu acestep "$@"
    fi

    exec "$@"
}

ensure_runtime_dirs
prepare_application_tree
configure_runtime_user
export_runtime_env
start_application
