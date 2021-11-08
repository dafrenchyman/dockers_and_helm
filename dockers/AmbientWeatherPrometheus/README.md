# AmbientWeatherPrometheus

Prometheus metric exporter for [Ambient Weather](https://ambientweather.com/) Stations

# Setup for development:

- Setup a python 3.x venv (usually in `.venv`)
- Install pip-tools: `pip3 install pip-tools`
- Update dev requirements: `pip-compile --output-file=requirements.dev.txt requirements.dev.in`
- Update requirements: `pip-compile --output-file=requirements.txt requirements.in`
- Install dev requirements: `pip3 install -r requirements.dev.txt`
- Install requirements: `pip3 install -r requirements.txt`
- Install pre-commit hook: `pre-commit install`

## Update versions

`pip-compile --output-file=requirements.dev.txt requirements.dev.in --upgrade`

# Run `pre-commit` locally.

`pre-commit run --all-files`

## Building and uploading the docker image

```bash
docker build . -t dafrenchyman/ambient-weather-prometheus-exporter
docker image push dafrenchyman/ambient-weather-prometheus-exporter
```

## Running the docker

-
- Get an API key from Ambient Weather.
- Run it with Docker

```bash
docker run \
  --restart=unless-stopped \
  -e AMBIENT_API_KEY=<Your Ambient API key> \
  -p 8000:8000 dafrenchyman/ambient-weather-prometheus-exporter:latest
```
