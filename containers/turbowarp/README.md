# TurboWarp container

This image builds the TurboWarp GUI/editor from `TurboWarp/scratch-gui` commit `a2946ee` and serves the production static files through the LinuxServer.io nginx runtime on port `80`.

## Runtime contract

- Runtime image: pinned LinuxServer.io nginx tag `1.30.4-r1-ls369`.
- Web root: LinuxServer.io nginx serves `/config/www`.
- Startup behavior: the image copies pinned TurboWarp static files into `/config/www` and installs the bundled nginx site config into `/config/nginx/site-confs/default.conf` on every container start.
- Supported LinuxServer-style environment variables: `PUID`, `PGID`, `TZ`, and `UMASK`.
- `/config` is optional. Mounting it persists nginx config, logs, and copied static files only. It is not required for children to create Scratch-compatible projects in the TurboWarp GUI.
- This image does not provide TurboWarp server-side accounts or project persistence.
- This image intentionally does not implement `turbowarp.org` wildcard aliases; it serves the default static TurboWarp build, including `/editor.html`.
- Requests to `/`, `/editor`, and `/editor/` redirect to the relative URI `/editor.html` so localhost port mappings such as `:8080` are preserved while the default local endpoint opens the Scratch-compatible editor instead of TurboWarp's upstream project-browser/player landing page.

## Build

```bash
docker build -t turbowarp:test containers/turbowarp
```

## Run

```bash
docker run --rm -d \
  --name turbowarp-test \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 18080:80 \
  turbowarp:test
```

Smoke-test the local GUI entrypoints:

```bash
curl -fsSI http://127.0.0.1:18080/ | grep -i '^location: /editor.html'
curl -fsSI http://127.0.0.1:18080/editor | grep -i '^location: /editor.html'
curl -fsS http://127.0.0.1:18080/editor.html >/tmp/turbowarp-editor.html
docker rm -f turbowarp-test
```

## Docker Compose

Use the committed example with the published image:

```bash
cp docker-compose.example.yml docker-compose.yml
docker compose up -d
```

This repository also keeps an ignored local `docker-compose.yml` in this directory for developer smoke tests with `build.context: .`.
