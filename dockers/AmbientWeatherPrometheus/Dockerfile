FROM python:3.8.10-slim

LABEL maintainer "julien.pierret@gmail.com"

WORKDIR /app
EXPOSE 8000

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

COPY ambient_weather.py /app/ambient_weather.py
COPY gauges.yaml /app/gauges.yaml

USER nobody

ENTRYPOINT ["python3", "/app/ambient_weather.py"]
