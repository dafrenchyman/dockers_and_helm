FROM ubuntu:focal

LABEL maintainer "julien.pierret@gmail.com"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip

WORKDIR /app
EXPOSE 8000

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

COPY ambient_weather.py /app/ambient_weather.py

USER nobody

ENTRYPOINT ["python3", "/app/ambient_weather.py"]
