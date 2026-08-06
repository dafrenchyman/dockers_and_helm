# Pegasus Plus container

## Baked inputs

- Base image: `ghcr.io/games-on-whales/pegasus:fedora`
- Published image: `ghcr.io/dafrenchyman/pegasus-plus:v0.1.0`
- Eden version: `v0.2.1`
- Eden AppImage: `https://stable.eden-emu.dev/v0.2.1/Eden-Linux-v0.2.1-amd64-gcc-standard.AppImage`
- Eden AppImage SHA-256: `2fae658397daf13c118082a3eb65d61a6519967b5e22e6667756baecf6000c5a`
- Eden launcher: `/Applications/launchers/eden.sh`
- Vita3K build: `4072`
- Vita3K AppImage: `https://github.com/Vita3K/Vita3K/releases/download/continuous/Vita3K-x86_64.AppImage`
- Vita3K AppImage SHA-256: `17535421aa81e98b545a4263d97dc6f20bfa5c3a23afc502e557427ddd1866a5`
- Vita3K launcher: `/Applications/launchers/vita3k.sh`
- shadPS4 version: `0.17.0`
- shadPS4 Linux SDL zip: `https://github.com/shadps4-emu/shadPS4/releases/download/v.0.17.0/shadps4-linux-sdl-0.17.0.zip`
- shadPS4 zip SHA-256: `0ad8ecbd2cfbdc1ea8fbc909638e0cba912235c6eb403d72faf9d4f67e925cc7`
- shadPS4 launcher: `/Applications/launchers/shadps4.sh`
- Azahar version: `2125.1.3`
- Azahar libretro core zip: `https://github.com/azahar-emu/azahar/releases/download/2125.1.3/azahar-libretro-linux-x86_64-2125.1.3.zip`
- Azahar libretro core SHA-256: `1d9fab3ac29b2e93b6bf8e9b2ffa2a20e85a2788f914cd873a0c3280ada9c8ae`
- Azahar libretro core: `/Applications/libretro_cores/azahar_libretro.so`
- Repo-owned Pegasus app metadata: `/cfg/app/metadata.pegasus.txt`, copied from `configs/app/metadata.pegasus.txt`
- Repo-owned Pegasus game directories: `/cfg/app/game_dirs.txt`, copied from `configs/app/game_dirs.txt`
- Repo-owned ROM launcher: `/Applications/launchers/rom_launcher.sh`, copied from `launchers/rom_launcher.sh`

## Runtime behavior

- Pegasus remains the container startup app from the upstream base.
- Eden appears in Pegasus Applications as `Emulators - Eden`.
- Vita3K appears in Pegasus Applications as `Emulators - Vita3K`.
- shadPS4 appears in Pegasus Applications as `Emulators - shadPS4`.
- Switch ROM launch commands in `/Applications/launchers/rom_launcher.sh` use `/Applications/launchers/eden.sh -f -g "{rom}"`.
- PlayStation Vita launch commands use the `psvita` key and run `/Applications/launchers/vita3k.sh -F -r "{rom}"`.
- PlayStation 4 launch commands use the `ps4` key and run `/Applications/launchers/shadps4.sh --fullscreen true -g "{rom}"`.
- Nintendo 3DS launch commands use the `n3ds` key and run RetroArch with the baked `/Applications/libretro_cores/azahar_libretro.so` core.
- The image does not download Eden, download Vita3K, download shadPS4, download Azahar, extract archives, or install packages at startup.

## Runtime paths

- Eden AppImage: `/Applications/eden-emu.AppImage`
- Vita3K AppImage: `/Applications/vita3k.AppImage`
- shadPS4 AppImage: `/Applications/shadps4-sdl.AppImage`
- Azahar libretro core: `/Applications/libretro_cores/azahar_libretro.so`
- Eden launcher: `/Applications/launchers/eden.sh`
- Vita3K launcher: `/Applications/launchers/vita3k.sh`
- shadPS4 launcher: `/Applications/launchers/shadps4.sh`
- ROM launcher: `/Applications/launchers/rom_launcher.sh`
- Pegasus application metadata: `/cfg/app/metadata.pegasus.txt`
- Pegasus game directories: `/cfg/app/game_dirs.txt`
- Switch ROMs: `/ROMs/switch`
- Nintendo 3DS entries: `/ROMs/n3ds`
- PlayStation Vita entries: `/ROMs/psvita`
- PlayStation 4 entries: `/ROMs/ps4`
- Emulator firmware and keys: `/bioses`, mounted by the operator. Do not bake keys or firmware into the image.

## Build

```bash
docker build -t pegasus-plus:test containers/pegasus-plus
```

## Structural smoke

```bash
docker run --rm --entrypoint /bin/bash pegasus-plus:test -lc 'test -x /Applications/eden-emu.AppImage && test -x /Applications/vita3k.AppImage && test -x /Applications/shadps4-sdl.AppImage && test -x /Applications/libretro_cores/azahar_libretro.so && test -x /Applications/launchers/eden.sh && test -x /Applications/launchers/vita3k.sh && test -x /Applications/launchers/shadps4.sh && test -x /Applications/launchers/rom_launcher.sh && grep -F "game: Emulators - Eden" /cfg/app/metadata.pegasus.txt && grep -F "game: Emulators - Vita3K" /cfg/app/metadata.pegasus.txt && grep -F "game: Emulators - shadPS4" /cfg/app/metadata.pegasus.txt && grep -F "/ROMs/n3ds" /cfg/app/game_dirs.txt && grep -F "/ROMs/psvita" /cfg/app/game_dirs.txt && grep -F "/ROMs/ps4" /cfg/app/game_dirs.txt && grep -F "[\"n3ds\"]=\"retroarch --fullscreen -L /Applications/libretro_cores/azahar_libretro.so \\\"\${ROM}\\\"\"" /Applications/launchers/rom_launcher.sh && grep -F "[\"switch\"]=\"/Applications/launchers/eden.sh -f -g \\\"\${ROM}\\\"\"" /Applications/launchers/rom_launcher.sh && grep -F "[\"psvita\"]=\"/Applications/launchers/vita3k.sh -F -r \\\"\${ROM}\\\"\"" /Applications/launchers/rom_launcher.sh && grep -F "[\"ps4\"]=\"/Applications/launchers/shadps4.sh --fullscreen true -g \\\"\${ROM}\\\"\"" /Applications/launchers/rom_launcher.sh'
```

## Docker Compose

Use the committed example with the published image:

```bash
cp docker-compose.example.yml docker-compose.yml
docker compose up -d
```

Adjust the ignored local `docker-compose.yml` host ROM, BIOS, and home mounts for the target machine.
