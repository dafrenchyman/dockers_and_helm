# Bluecherry Server Docker

All this container does is it takes the [bluecherry-docker](https://github.com/bluecherrydvr/bluecherry-docker) image from [here](https://hub.docker.com/r/sicadaco/bluecherry-server) and fixes it so the gid and uid can be assigned at run-time.

You should still use the docker-compose from there but swap out `sicadaco/bluecherry-server:latest` with `dafrenchyman/bluecherry-server:latest`

```bash
docker build . -t dafrenchyman/bluecherry-server
docker image push dafrenchyman/bluecherry-server
```
