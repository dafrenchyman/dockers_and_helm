#!/usr/bin/env python
import logging
import os
import sys
import time

import yaml
from ambient_api.ambientapi import AmbientAPI
from prometheus_client import Gauge, start_http_server
from yaml import BaseLoader

logging.basicConfig(
    format="[%(asctime)s] {%(pathname)s:%(lineno)d} %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    stream=sys.stdout,
    level=logging.INFO,
)

APPLICATION_KEY = "b31a8cd9869345c986310f002f97eb1f0ffd7192d13547b4ae80643203b34f72"  # pragma: allowlist secret


def generate_gauges(available_metrics, subsystem=""):
    # Load Gauges from yaml
    with open("./gauges.yaml", "r") as stream:
        all_gauges = yaml.load(stream=stream, Loader=BaseLoader)

    gauges = {}
    for i in available_metrics:
        if i in all_gauges.keys():
            gauges[i] = Gauge(
                name=all_gauges[i]["name"],
                documentation=all_gauges[i]["documentation"],
                subsystem=subsystem,
                unit=all_gauges[i]["unit"],
            )
    return gauges


def main():
    API = AmbientAPI(
        AMBIENT_API_KEY=os.environ["AMBIENT_API_KEY"],
        AMBIENT_APPLICATION_KEY=APPLICATION_KEY,
        AMBIENT_ENDPOINT="https://api.ambientweather.net/v1",
    )
    if not API.api_key:
        raise Exception("API Key not submitted")
    if not API.application_key:
        raise Exception("You must specify an Application Key")

    locations = {}
    start_http_server(8000)
    while True:
        devices = API.get_devices()
        for idx, device in enumerate(devices):
            last_data = device.last_data
            if idx not in locations.keys():
                locations[idx] = generate_gauges(
                    available_metrics=last_data, subsystem=device.info["name"]
                )
            gauges = locations[idx]

            now = time.time()
            if last_data["dateutc"] / 1000 < now - 120:
                raise Exception(
                    "Stale data from Ambient API; dateutc={}, now={}".format(
                        last_data["dateutc"], now
                    )
                )

            logging.info(device.info)
            logging.info(device.mac_address)
            logging.info(last_data)
            for gauge_name in gauges:
                gauges[gauge_name].set(last_data[gauge_name])
        logging.info("Sleeping 60s")
        time.sleep(60)


if __name__ == "__main__":
    main()
