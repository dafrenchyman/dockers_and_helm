ARG GOW_PEGASUS_IMAGE=ghcr.io/games-on-whales/pegasus:fedora
FROM ${GOW_PEGASUS_IMAGE}

ARG EDEN_VERSION=0.2.1
ARG EDEN_APPIMAGE_URL=https://stable.eden-emu.dev/v0.2.1/Eden-Linux-v0.2.1-amd64-gcc-standard.AppImage
ARG EDEN_APPIMAGE_SHA256=2fae658397daf13c118082a3eb65d61a6519967b5e22e6667756baecf6000c5a

LABEL org.opencontainers.image.title="Pegasus Eden"
LABEL org.opencontainers.image.description="Games on Whales Pegasus frontend with Eden Nintendo Switch emulator integration"
LABEL org.opencontainers.image.source="https://github.com/dafrenchyman/dockers_and_helm"

ENV APPIMAGE_EXTRACT_AND_RUN=1

RUN set -eux; \
    curl -fsSL "${EDEN_APPIMAGE_URL}" -o /Applications/eden-emu.AppImage; \
    printf '%s  %s\n' "${EDEN_APPIMAGE_SHA256}" /Applications/eden-emu.AppImage | sha256sum -c -; \
    chmod 777 /Applications/eden-emu.AppImage

COPY --chmod=777 launchers/eden.sh /Applications/launchers/eden.sh

RUN set -eux; \
    sed -i '/^  \/Applications\/launchers\/citron.sh$/a\  /Applications/launchers/eden.sh' /cfg/app/metadata.pegasus.txt; \
    printf '%s\n' \
        'game: Emulators - Eden' \
        'release: 2026-06-01' \
        'file: /Applications/launchers/eden.sh' \
        'description: Eden is an open-source Nintendo Switch emulator. This image packages Eden v0.2.1 as a Linux AppImage and launches it through the Games on Whales Pegasus frontend.' \
        '' \
        >/tmp/eden-metadata.pegasus.txt; \
    awk 'BEGIN { while ((getline line < "/tmp/eden-metadata.pegasus.txt") > 0) eden = eden line ORS } /^game: Emulators - RPCS3$/ { printf "%s", eden } { print }' /cfg/app/metadata.pegasus.txt >/tmp/metadata.pegasus.txt; \
    mv /tmp/metadata.pegasus.txt /cfg/app/metadata.pegasus.txt; \
    grep -F '  /Applications/launchers/eden.sh' /cfg/app/metadata.pegasus.txt; \
    grep -F 'game: Emulators - Eden' /cfg/app/metadata.pegasus.txt; \
    grep -F 'release: 2026-06-01' /cfg/app/metadata.pegasus.txt; \
    grep -F 'file: /Applications/launchers/eden.sh' /cfg/app/metadata.pegasus.txt

RUN set -eux; \
    grep -F '["switch"]="/Applications/launchers/citron.sh -f -g \"${ROM}\"" \' /Applications/launchers/rom_launcher.sh; \
    sed -i 's#\["switch"\]="/Applications/launchers/citron.sh -f -g \\"${ROM}\\"" \\#["switch"]="/Applications/launchers/eden.sh -f -g \\"${ROM}\\"" \\#' /Applications/launchers/rom_launcher.sh; \
    grep -F '["switch"]="/Applications/launchers/eden.sh -f -g \"${ROM}\"" \' /Applications/launchers/rom_launcher.sh
