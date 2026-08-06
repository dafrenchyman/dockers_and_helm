# Pegasus Eden container

## Baked inputs

- Base image: `ghcr.io/games-on-whales/pegasus:fedora`
- Eden version: `v0.2.1`
- Eden AppImage: `https://stable.eden-emu.dev/v0.2.1/Eden-Linux-v0.2.1-amd64-gcc-standard.AppImage`
- Eden AppImage SHA-256: `2fae658397daf13c118082a3eb65d61a6519967b5e22e6667756baecf6000c5a`
- Eden launcher: `/Applications/launchers/eden.sh`

## Runtime behavior

- Pegasus remains the container startup app from the upstream base.
- Eden appears in Pegasus Applications as `Emulators - Eden`.
- Switch ROM launch commands in `/Applications/launchers/rom_launcher.sh` use `/Applications/launchers/eden.sh -f -g "{rom}"`.
- The image does not download Eden or install packages at startup.

## Runtime paths

- Eden AppImage: `/Applications/eden-emu.AppImage`
- Eden launcher: `/Applications/launchers/eden.sh`
- Pegasus application metadata: `/cfg/app/metadata.pegasus.txt`
- Switch ROMs: `/ROMs/switch`
- Emulator firmware and keys: `/bioses`, mounted by the operator. Do not bake keys or firmware into the image.

## Build

```bash
docker build -t pegasus-eden:test containers/pegasus-eden
```

## Structural smoke

```bash
docker run --rm --entrypoint /bin/bash pegasus-eden:test -lc 'test -x /Applications/eden-emu.AppImage && test -x /Applications/launchers/eden.sh && grep -F "game: Emulators - Eden" /cfg/app/metadata.pegasus.txt && grep -F "[\"switch\"]=\"/Applications/launchers/eden.sh -f -g \\\"\${ROM}\\\"\"" /Applications/launchers/rom_launcher.sh'
```

## Docker Compose

Use the committed example with the published image:

```bash
cp docker-compose.example.yml docker-compose.yml
docker compose up -d
```

Adjust the ignored local `docker-compose.yml` host ROM, BIOS, and home mounts for the target machine.
