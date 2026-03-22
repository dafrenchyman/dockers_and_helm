#!/bin/sh

set -eu

APP_HOME="${APP_HOME:-/opt/comfyui}"
COMFYUI_USER_DIR="${COMFYUI_USER_DIR:-${APP_HOME}/user}"
COMFYUI_MUTABLE_CUSTOM_NODES_DIR="${COMFYUI_MUTABLE_CUSTOM_NODES_DIR:-${APP_HOME}/custom_nodes}"
COMFYUI_BAKED_CUSTOM_NODES_DIR="${COMFYUI_BAKED_CUSTOM_NODES_DIR:-${APP_HOME}/baked_custom_nodes}"
COMFYUI_SENTINEL_STATE_DIR="${COMFYUI_SENTINEL_STATE_DIR:-${APP_HOME}/state/sentinel}"
COMFYUI_TEMP_DIR="${COMFYUI_TEMP_DIR:-${COMFYUI_USER_DIR}/temp}"
COMFYUI_DB_PATH="${COMFYUI_DB_PATH:-/tmp/comfyui-runtime.db}"
COMFYUI_HOST="${COMFYUI_HOST:-0.0.0.0}"
COMFYUI_PORT="${COMFYUI_PORT:-8188}"
COMFYUI_EXTRA_ARGS="${COMFYUI_EXTRA_ARGS:-}"
COMFYUI_RESET_DB_ON_START="${COMFYUI_RESET_DB_ON_START:-true}"
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
SENTINEL_SECRET_ENV="${SENTINEL_SECRET_ENV:-SECRET_KEY}"
SENTINEL_MANAGER_ADMIN_ONLY="${SENTINEL_MANAGER_ADMIN_ONLY:-true}"
SENTINEL_SEPARATE_USERS="${SENTINEL_SEPARATE_USERS:-true}"
SENTINEL_ACCESS_TOKEN_EXPIRATION_HOURS="${SENTINEL_ACCESS_TOKEN_EXPIRATION_HOURS:-12}"
SENTINEL_MAX_ACCESS_TOKEN_EXPIRATION_HOURS="${SENTINEL_MAX_ACCESS_TOKEN_EXPIRATION_HOURS:-8760}"
COMFYUI_MANAGER_NETWORK_MODE="${COMFYUI_MANAGER_NETWORK_MODE:-public}"
COMFYUI_MANAGER_USE_UV="${COMFYUI_MANAGER_USE_UV:-False}"
COMFYUI_MANAGER_ALWAYS_LAZY_INSTALL="${COMFYUI_MANAGER_ALWAYS_LAZY_INSTALL:-False}"
COMFYUI_MANAGER_DEFAULT_CACHE_AS_CHANNEL_URL="${COMFYUI_MANAGER_DEFAULT_CACHE_AS_CHANNEL_URL:-False}"
COMFYUI_MANAGER_FILE_LOGGING="${COMFYUI_MANAGER_FILE_LOGGING:-False}"

ensure_runtime_dirs() {
    mkdir -p \
        "${APP_HOME}/models/checkpoints" \
        "${APP_HOME}/models/clip" \
        "${APP_HOME}/models/clip_vision" \
        "${APP_HOME}/models/configs" \
        "${APP_HOME}/models/controlnet" \
        "${APP_HOME}/models/diffusion_models" \
        "${APP_HOME}/models/embeddings" \
        "${APP_HOME}/models/loras" \
        "${APP_HOME}/models/upscale_models" \
        "${APP_HOME}/models/vae" \
        "${APP_HOME}/input" \
        "${APP_HOME}/output" \
        "${COMFYUI_MUTABLE_CUSTOM_NODES_DIR}" \
        "${COMFYUI_SENTINEL_STATE_DIR}" \
        "${COMFYUI_USER_DIR}" \
        "${COMFYUI_TEMP_DIR}" \
        "${COMFYUI_USER_DIR}/__manager"
}

configure_runtime_user() {
    if [ "$(id -u)" -ne 0 ]; then
        return
    fi

    if [ "$(getent group comfy | cut -d: -f3)" != "${PGID}" ]; then
        groupmod -o -g "${PGID}" comfy
    fi

    if [ "$(id -u comfy)" != "${PUID}" ]; then
        usermod -o -u "${PUID}" comfy
    fi

    chown -R "${PUID}:${PGID}" \
        "${APP_HOME}/models" \
        "${APP_HOME}/input" \
        "${APP_HOME}/output" \
        "${COMFYUI_MUTABLE_CUSTOM_NODES_DIR}" \
        "${COMFYUI_SENTINEL_STATE_DIR}" \
        "${COMFYUI_USER_DIR}" \
        "${COMFYUI_TEMP_DIR}" \
        /home/comfy
}

write_sentinel_config() {
    cat > "${COMFYUI_BAKED_CUSTOM_NODES_DIR}/ComfyUI-Sentinel/config.json" <<EOF
{
  "secret_key_env": "${SENTINEL_SECRET_ENV}",
  "users_db": "${COMFYUI_SENTINEL_STATE_DIR}/users_db.json",
  "access_token_expiration_hours": ${SENTINEL_ACCESS_TOKEN_EXPIRATION_HOURS},
  "max_access_token_expiration_hours": ${SENTINEL_MAX_ACCESS_TOKEN_EXPIRATION_HOURS},
  "log": "${COMFYUI_SENTINEL_STATE_DIR}/sentinel.log",
  "log_levels": ["INFO"],
  "whitelist": "${COMFYUI_SENTINEL_STATE_DIR}/whitelist.txt",
  "blacklist": "${COMFYUI_SENTINEL_STATE_DIR}/blacklist.txt",
  "blacklist_after_attempts": 0,
  "free_memory_on_logout": false,
  "force_https": false,
  "separate_users": ${SENTINEL_SEPARATE_USERS},
  "manager_admin_only": ${SENTINEL_MANAGER_ADMIN_ONLY}
}
EOF
}

write_manager_config() {
    cat > "${COMFYUI_USER_DIR}/__manager/config.ini" <<EOF
[default]
use_uv = ${COMFYUI_MANAGER_USE_UV}
default_cache_as_channel_url = ${COMFYUI_MANAGER_DEFAULT_CACHE_AS_CHANNEL_URL}
file_logging = ${COMFYUI_MANAGER_FILE_LOGGING}
always_lazy_install = ${COMFYUI_MANAGER_ALWAYS_LAZY_INSTALL}
network_mode = ${COMFYUI_MANAGER_NETWORK_MODE}
EOF
}

link_baked_custom_nodes() {
    copy_custom_node "ComfyUI-Manager" "comfyui-manager"
    copy_custom_node "ComfyUI-Sentinel" "ComfyUI-Sentinel"
}

copy_custom_node() {
    source_name="$1"
    target_name="$2"
    source_dir="${COMFYUI_BAKED_CUSTOM_NODES_DIR}/${source_name}"
    target_dir="${COMFYUI_MUTABLE_CUSTOM_NODES_DIR}/${target_name}"

    rm -rf "${target_dir}"
    mkdir -p "${target_dir}"
    cp -a "${source_dir}/." "${target_dir}/"
}

reset_comfyui_db_if_requested() {
    if [ "${COMFYUI_RESET_DB_ON_START}" != "true" ]; then
        return
    fi

    rm -f \
        "${COMFYUI_DB_PATH}" \
        "${COMFYUI_DB_PATH}-wal" \
        "${COMFYUI_DB_PATH}-shm" \
        "${COMFYUI_DB_PATH}-journal"
}

start_comfyui() {
    set -- python main.py --listen "${COMFYUI_HOST}" --port "${COMFYUI_PORT}" --user-directory "${COMFYUI_USER_DIR}" --temp-directory "${COMFYUI_TEMP_DIR}" --database-url "sqlite:///${COMFYUI_DB_PATH}"

    if [ -n "${COMFYUI_EXTRA_ARGS}" ]; then
        # shellcheck disable=SC2086
        set -- "$@" ${COMFYUI_EXTRA_ARGS}
    fi

    if [ "$(id -u)" -eq 0 ]; then
        export HOME=/home/comfy
        exec gosu comfy "$@"
    fi

    exec "$@"
}

ensure_runtime_dirs
configure_runtime_user
write_sentinel_config
write_manager_config
link_baked_custom_nodes
reset_comfyui_db_if_requested
start_comfyui
