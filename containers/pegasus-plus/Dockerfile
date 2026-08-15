ARG GOW_PEGASUS_IMAGE=ghcr.io/games-on-whales/pegasus:fedora
FROM ${GOW_PEGASUS_IMAGE}

ARG EDEN_VERSION=0.2.1
ARG EDEN_APPIMAGE_URL=https://stable.eden-emu.dev/v0.2.1/Eden-Linux-v0.2.1-amd64-gcc-standard.AppImage
ARG EDEN_APPIMAGE_SHA256=2fae658397daf13c118082a3eb65d61a6519967b5e22e6667756baecf6000c5a
ARG VITA3K_VERSION=4072
ARG VITA3K_APPIMAGE_URL=https://github.com/Vita3K/Vita3K/releases/download/continuous/Vita3K-x86_64.AppImage
ARG VITA3K_APPIMAGE_SHA256=17535421aa81e98b545a4263d97dc6f20bfa5c3a23afc502e557427ddd1866a5
ARG SHADPS4_VERSION=0.17.0
ARG SHADPS4_ZIP_URL=https://github.com/shadps4-emu/shadPS4/releases/download/v.0.17.0/shadps4-linux-sdl-0.17.0.zip
ARG SHADPS4_ZIP_SHA256=0ad8ecbd2cfbdc1ea8fbc909638e0cba912235c6eb403d72faf9d4f67e925cc7
ARG AZAHAR_VERSION=2125.1.3
ARG AZAHAR_LIBRETRO_URL=https://github.com/azahar-emu/azahar/releases/download/2125.1.3/azahar-libretro-linux-x86_64-2125.1.3.zip
ARG AZAHAR_LIBRETRO_SHA256=1d9fab3ac29b2e93b6bf8e9b2ffa2a20e85a2788f914cd873a0c3280ada9c8ae

LABEL org.opencontainers.image.title="Pegasus Plus"
LABEL org.opencontainers.image.description="Games on Whales Pegasus frontend with additional emulator integrations"
LABEL org.opencontainers.image.source="https://github.com/dafrenchyman/dockers_and_helm"

ENV APPIMAGE_EXTRACT_AND_RUN=1

RUN set -eux; \
    dnf install -y 7zip; \
    dnf clean all

RUN set -eux; \
    curl -fsSL "${EDEN_APPIMAGE_URL}" -o /Applications/eden-emu.AppImage; \
    printf '%s  %s\n' "${EDEN_APPIMAGE_SHA256}" /Applications/eden-emu.AppImage | sha256sum -c -; \
    chmod 777 /Applications/eden-emu.AppImage

RUN set -eux; \
    curl -fsSL "${VITA3K_APPIMAGE_URL}" -o /Applications/vita3k.AppImage; \
    printf '%s  %s\n' "${VITA3K_APPIMAGE_SHA256}" /Applications/vita3k.AppImage | sha256sum -c -; \
    chmod 777 /Applications/vita3k.AppImage

RUN set -eux; \
    curl -fsSL "${SHADPS4_ZIP_URL}" -o /tmp/shadps4.zip; \
    printf '%s  %s\n' "${SHADPS4_ZIP_SHA256}" /tmp/shadps4.zip | sha256sum -c -; \
    7za e -y /tmp/shadps4.zip Shadps4-sdl.AppImage -o/Applications >/dev/null; \
    rm /tmp/shadps4.zip; \
    mv /Applications/Shadps4-sdl.AppImage /Applications/shadps4-sdl.AppImage; \
    chmod 777 /Applications/shadps4-sdl.AppImage

RUN set -eux; \
    mkdir -p /Applications/libretro_cores; \
    curl -fsSL "${AZAHAR_LIBRETRO_URL}" -o /tmp/azahar-libretro.zip; \
    printf '%s  %s\n' "${AZAHAR_LIBRETRO_SHA256}" /tmp/azahar-libretro.zip | sha256sum -c -; \
    7za e -y /tmp/azahar-libretro.zip azahar_libretro.so -o/Applications/libretro_cores >/dev/null; \
    rm /tmp/azahar-libretro.zip; \
    chmod 777 /Applications/libretro_cores/azahar_libretro.so

COPY --chmod=777 launchers/eden.sh /Applications/launchers/eden.sh
COPY --chmod=777 launchers/vita3k.sh /Applications/launchers/vita3k.sh
COPY --chmod=777 launchers/shadps4.sh /Applications/launchers/shadps4.sh
COPY --chmod=777 launchers/rom_launcher.sh /Applications/launchers/rom_launcher.sh
COPY configs/app/metadata.pegasus.txt /cfg/app/metadata.pegasus.txt
COPY configs/app/game_dirs.txt /cfg/app/game_dirs.txt

