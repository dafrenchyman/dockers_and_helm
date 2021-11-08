#!/usr/bin/env python
import logging
import os
import time

from ambient_api.ambientapi import AmbientAPI
from prometheus_client import Gauge, start_http_server

APPLICATION_KEY = "b31a8cd9869345c986310f002f97eb1f0ffd7192d13547b4ae80643203b34f72"  # pragma: allowlist secret

ALL_GAUGES = {
    "24hourrainin": {
        "name": "rain24hour",
        "documentation": "24 Hour Rain, in",
        "unit": "inches",
    },
    "baromabsin": {
        "name": "baromabsin",
        "documentation": "Absolute Pressure, inHg",
        "unit": "inHg",
    },
    "baromrelin": {
        "name": "baromrelin",
        "documentation": "Relative Pressure, inHg",
        "unit": "inHg",
    },
    "batt1": {
        "name": "outdoorBattery1",
        "documentation": "Outdoor Battery 1 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt2": {
        "name": "outdoorBattery2",
        "documentation": "Outdoor Battery 2 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt3": {
        "name": "outdoorBattery3",
        "documentation": "Outdoor Battery 3 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt4": {
        "name": "outdoorBattery4",
        "documentation": "Outdoor Battery 4 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt5": {
        "name": "outdoorBattery5",
        "documentation": "Outdoor Battery 5 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt6": {
        "name": "outdoorBattery6",
        "documentation": "Outdoor Battery 6 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt7": {
        "name": "outdoorBattery7",
        "documentation": "Outdoor Battery 7 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt8": {
        "name": "outdoorBattery8",
        "documentation": "Outdoor Battery 8 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt9": {
        "name": "outdoorBattery9",
        "documentation": "Outdoor Battery 9 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt10": {
        "name": "outdoorBattery10",
        "documentation": "Outdoor Battery 10 - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "battout": {
        "name": "outdoorBattery",
        "documentation": "Outdoor Battery - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "battin": {
        "name": "indoorBattery",
        "documentation": "Indoor Battery - OK/Low indication, Int, 1=OK, 0=Low (Meteobridge Users 1=Low, 0=OK)",
        "unit": "int",
    },
    "batt_25": {
        "name": "airQualityBattery",
        "documentation": (
            "PM2.5 Air Quality Sensor Battery indication, OK/Low indication, Int, 1=OK, 0=Low"
            + " (Meteobridge Users 1=Low, 0=OK)"
        ),
        "unit": "int",
    },
    "batt_lightning": {
        "name": "lightningBattery",
        "documentation": "Lightning Detector Battery - 1=Low 0=OK",
        "unit": "int",
    },
    "batleak1": {
        "name": "leakDetectorBattery1",
        "documentation": "Leak Detector Battery 1 - 1=Low 0=OK",
        "unit": "int",
    },
    "batleak2": {
        "name": "leakDetectorBattery2",
        "documentation": "Leak Detector Battery 2 - 1=Low 0=OK",
        "unit": "int",
    },
    "batleak3": {
        "name": "leakDetectorBattery3",
        "documentation": "Leak Detector Battery 3 - 1=Low 0=OK",
        "unit": "int",
    },
    "batleak4": {
        "name": "leakDetectorBattery4",
        "documentation": "Leak Detector Battery 4 - 1=Low 0=OK",
        "unit": "int",
    },
    "battsm1": {
        "name": "soilMoistureBattery1",
        "documentation": "Soil Moisture Battery 1 - 1=OK, 0=Low",
        "unit": "int",
    },
    "battsm2": {
        "name": "soilMoistureBattery2",
        "documentation": "Soil Moisture Battery 2 - 1=OK, 0=Low",
        "unit": "int",
    },
    "battsm3": {
        "name": "soilMoistureBattery3",
        "documentation": "Soil Moisture Battery 3 - 1=OK, 0=Low",
        "unit": "int",
    },
    "battsm4": {
        "name": "soilMoistureBattery4",
        "documentation": "Soil Moisture Battery 4 - 1=OK, 0=Low",
        "unit": "int",
    },
    "batt_co2": {
        "name": "CO2Battery",
        "documentation": "CO2 battery - 1=OK, 0=Low",
        "unit": "int",
    },
    "batt_cellgateway": {
        "name": "cellularGatewayBattery",
        "documentation": "Cellular Gateway - 1=OK, 0=Low",
        "unit": "int",
    },
    "co2": {
        "name": "co2",
        "documentation": "CO2 Meter",
        "unit": "ppm",
    },
    "dailyrainin": {
        "name": "rainDaily",
        "documentation": "Daily Rain, in",
        "unit": "inches",
    },
    "dateutc": {
        "name": "dateUTC",
        "documentation": "Datetime, int (milliseconds from 01-01-1970, rounded down to nearest minute on server)",
        "unit": "milliSeconds",
    },
    "dewPoint": {
        "name": "outdoorDewPoint",
        "documentation": "Outdoor Dew Point",
        "unit": "degreesFahrenheit",
    },
    "dewPoint1": {
        "name": "outdoorDewPoint1",
        "documentation": "Outdoor Dew Point (Sensor 1)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint2": {
        "name": "outdoorDewPoint2",
        "documentation": "Outdoor Dew Point (Sensor 2)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint3": {
        "name": "outdoorDewPoint3",
        "documentation": "Outdoor Dew Point (Sensor 3)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint4": {
        "name": "outdoorDewPoint4",
        "documentation": "Outdoor Dew Point (Sensor 4)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint5": {
        "name": "outdoorDewPoint5",
        "documentation": "Outdoor Dew Point (Sensor 5)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint6": {
        "name": "outdoorDewPoint6",
        "documentation": "Outdoor Dew Point (Sensor 6)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint7": {
        "name": "outdoorDewPoint7",
        "documentation": "Outdoor Dew Point (Sensor 7)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint8": {
        "name": "outdoorDewPoint8",
        "documentation": "Outdoor Dew Point (Sensor 8)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint9": {
        "name": "outdoorDewPoint9",
        "documentation": "Outdoor Dew Point (Sensor 9)",
        "unit": "degreesFahrenheit",
    },
    "dewPoint10": {
        "name": "outdoorDewPoint10",
        "documentation": "Outdoor Dew Point (Sensor 10)",
        "unit": "degreesFahrenheit",
    },
    "dewPointin": {
        "name": "indoorDewPoint",
        "documentation": "Indoor Dew Point",
        "unit": "degreesFahrenheit",
    },
    "eventrainin": {
        "name": "rainEvent",
        "documentation": "Event Rain, in",
        "unit": "inches",
    },
    "feelsLike": {
        "name": "outdoorFeelsLike",
        "documentation": "if < 50ºF => Wind Chill, if > 68ºF => Heat Index Outdoor",
        "unit": "degreesFahrenheit",
    },
    "feelsLike1": {
        "name": "outdoorFeelsLike1",
        "documentation": "if < 50ºF => Wind Chill, if > 68ºF => Heat Index Outdoor (Sensor 1)",
        "unit": "degreesFahrenheit",
    },
    "feelsLikein": {
        "name": "indoorFeelsLike",
        "documentation": "Indoor Feels Like",
        "unit": "degreesFahrenheit",
    },
    "hourlyrainin": {
        "name": "indoorRainHourly",
        "documentation": "Hourly Rain Rate, in/hr",
        "unit": "inchesPerHour",
    },
    "humidity": {
        "name": "outdoorHumidity",
        "documentation": "Outdoor Humidity, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity1": {
        "name": "outdoorHumidity1",
        "documentation": "Outdoor Humidity, sensor 1, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity2": {
        "name": "outdoorHumidity2",
        "documentation": "Outdoor Humidity, sensor 2, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity3": {
        "name": "outdoorHumidity3",
        "documentation": "Outdoor Humidity, sensor 3, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity4": {
        "name": "outdoorHumidity4",
        "documentation": "Outdoor Humidity, sensor 4, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity5": {
        "name": "outdoorHumidity5",
        "documentation": "Outdoor Humidity, sensor 5, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity6": {
        "name": "outdoorHumidity6",
        "documentation": "Outdoor Humidity, sensor 6, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity7": {
        "name": "outdoorHumidity7",
        "documentation": "Outdoor Humidity, sensor 7, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity8": {
        "name": "outdoorHumidity8",
        "documentation": "Outdoor Humidity, sensor 8, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity9": {
        "name": "outdoorHumidity9",
        "documentation": "Outdoor Humidity, sensor 9, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidity10": {
        "name": "outdoorHumidity6",
        "documentation": "Outdoor Humidity, sensor 10, 0-100%",
        "unit": "relativeHumidity",
    },
    "humidityin": {
        "name": "indoorHumidity",
        "documentation": "Indoor Humidity, 0-100%",
        "unit": "relativeHumidity",
    },
    # "lastRain": {
    #     "name": "rainLast",
    #     "documentation": "Last time hourlyrainin > 0",
    #     "unit": "date",
    # },
    "lightning_day": {
        "name": "lightningStrikesDay",
        "documentation": "Lightning strikes per day",
        "unit": "count",
    },
    "lightning_hour": {
        "name": "lightningStrikesHour",
        "documentation": " Lightning strikes per hour",
        "unit": "count",
    },
    "lightning_time": {
        "name": "lightningLastStikeTime",
        "documentation": "Last strike",
        "unit": "datetime",
    },
    "lightning_distance": {
        "name": "windGustDailyMax",
        "documentation": "Distance of last lightning strike",
        "unit": "miles",
    },
    "maxdailygust": {
        "name": "windGustDailyMax",
        "documentation": "Maximum wind speed in last day",
        "unit": "mph",
    },
    "monthlyrainin": {
        "name": "rainMonthly",
        "documentation": "Monthly Rain, in",
        "unit": "Inches",
    },
    "pm25": {
        "name": "outdoorAirQuality",
        "documentation": "PM2.5 Air Quality, Float, µg/m^3",
        "unit": "MuGOverMetersCubed",
    },
    "pm25_24h": {
        "name": "outdoorAirQuality24Hours",
        "documentation": "PM2.5 Air Quality 24 hour average, Float, µg/m^3",
        "unit": "MuGOverMetersCubed",
    },
    "pm25_in": {
        "name": "indoorAirQuality",
        "documentation": "PM2.5 Air Quality, Indoor, Float, µg/m^3",
        "unit": "MuGOverMetersCubed",
    },
    "pm25_in_24h": {
        "name": "indoorAirQuality24Hours",
        "documentation": "PM2.5 Air Quality 24 hour average, Indoor, Float, µg/m^3",
        "unit": "MuGOverMetersCubed",
    },
    "relay1": {
        "name": "relay1",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay2": {
        "name": "relay2",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay3": {
        "name": "relay3",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay4": {
        "name": "relay4",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay5": {
        "name": "relay5",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay6": {
        "name": "relay6",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay7": {
        "name": "relay7",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay8": {
        "name": "relay8",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay9": {
        "name": "relay9",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "relay10": {
        "name": "relay10",
        "documentation": "0 or 1",
        "unit": "bool",
    },
    "solarradiation": {
        "name": "solar_radiation",
        "documentation": "Solar Radiation, W/m^2",
        "unit": "wattsPerMeterSquared",
    },
    "soilhum1": {
        "name": "soilHumidity1",
        "documentation": "Soil Humidity 1 %",
        "unit": "relativeHumidity",
    },
    "soilhum2": {
        "name": "soilHumidity2",
        "documentation": "Soil Humidity 2 %",
        "unit": "relativeHumidity",
    },
    "soilhum3": {
        "name": "soilHumidity3",
        "documentation": "Soil Humidity 3 %",
        "unit": "relativeHumidity",
    },
    "soilhum4": {
        "name": "soilHumidity4",
        "documentation": "Soil Humidity 4 %",
        "unit": "relativeHumidity",
    },
    "soilhum5": {
        "name": "soilHumidity5",
        "documentation": "Soil Humidity 5 %",
        "unit": "relativeHumidity",
    },
    "soilhum6": {
        "name": "soilHumidity6",
        "documentation": "Soil Humidity 6 %",
        "unit": "relativeHumidity",
    },
    "soilhum7": {
        "name": "soilHumidity7",
        "documentation": "Soil Humidity 7 %",
        "unit": "relativeHumidity",
    },
    "soilhum8": {
        "name": "soilHumidity8",
        "documentation": "Soil Humidity 8 %",
        "unit": "relativeHumidity",
    },
    "soilhum9": {
        "name": "soilHumidity9",
        "documentation": "Soil Humidity 9 %",
        "unit": "relativeHumidity",
    },
    "soilhum10": {
        "name": "soilHumidity10",
        "documentation": "Soil Humidity 10 %",
        "unit": "relativeHumidity",
    },
    "soiltemp1f": {
        "name": "soilTemperature1",
        "documentation": "Soil Temperature 1 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp2f": {
        "name": "soilTemperature2",
        "documentation": "Soil Temperature 2 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp3f": {
        "name": "soilTemperature3",
        "documentation": "Soil Temperature 3 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp4f": {
        "name": "soilTemperature4",
        "documentation": "Soil Temperature 4 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp5f": {
        "name": "soilTemperature5",
        "documentation": "Soil Temperature 5 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp6f": {
        "name": "soilTemperature6",
        "documentation": "Soil Temperature 6 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp7f": {
        "name": "soilTemperature7",
        "documentation": "Soil Temperature 7 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp8f": {
        "name": "soilTemperature8",
        "documentation": "Soil Temperature 8 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp9f": {
        "name": "soilTemperature9",
        "documentation": "Soil Temperature 9 ºF",
        "unit": "degreesFahrenheit",
    },
    "soiltemp10f": {
        "name": "soilTemperature10",
        "documentation": "Soil Temperature 10 ºF",
        "unit": "degreesFahrenheit",
    },
    "tempf": {
        "name": "outdoorTemperature",
        "documentation": "Outdoor Temperature ºF",
        "unit": "degreesFahrenheit",
    },
    "tempf1": {
        "name": "outdoorTemperature1",
        "documentation": "Outdoor Temperature ºF (Sensor 1)",
        "unit": "degreesFahrenheit",
    },
    "tempf2": {
        "name": "outdoorTemperature2",
        "documentation": "Outdoor Temperature ºF (Sensor 2)",
        "unit": "degreesFahrenheit",
    },
    "tempf3": {
        "name": "outdoorTemperature3",
        "documentation": "Outdoor Temperature ºF (Sensor 3)",
        "unit": "degreesFahrenheit",
    },
    "tempf4": {
        "name": "outdoorTemperature4",
        "documentation": "Outdoor Temperature ºF (Sensor 4)",
        "unit": "degreesFahrenheit",
    },
    "tempf5": {
        "name": "outdoorTemperature5",
        "documentation": "Outdoor Temperature ºF (Sensor 5)",
        "unit": "degreesFahrenheit",
    },
    "tempf6": {
        "name": "outdoorTemperature6",
        "documentation": "Outdoor Temperature ºF (Sensor 6)",
        "unit": "degreesFahrenheit",
    },
    "tempf7": {
        "name": "outdoorTemperature7",
        "documentation": "Outdoor Temperature ºF (Sensor 7)",
        "unit": "degreesFahrenheit",
    },
    "tempf8": {
        "name": "outdoorTemperature8",
        "documentation": "Outdoor Temperature ºF (Sensor 8)",
        "unit": "degreesFahrenheit",
    },
    "tempf9": {
        "name": "outdoorTemperature9",
        "documentation": "Outdoor Temperature ºF (Sensor 9)",
        "unit": "degreesFahrenheit",
    },
    "tempf10": {
        "name": "outdoorTemperature10",
        "documentation": "Outdoor Temperature ºF (Sensor 10)",
        "unit": "degreesFahrenheit",
    },
    "tempinf": {
        "name": "indoor_temperature",
        "documentation": "Indoor Temperature ºF)",
        "unit": "degreesFahrenheit",
    },
    "totalrainin": {
        "name": "rain_total",
        "documentation": "Total Rain, in (since last factory reset)",
        "unit": "inches",
    },
    # "tz": {
    #     "name": "tz",
    #     "documentation": "IANA Time Zone, String",
    #     "unit": "timezone"
    # },
    "uv": {
        "name": "uv",
        "documentation": "Ultra-Violet Radiation Index, integer on all devices EXCEPT WS-8478.",
        "unit": "index",
    },
    "winddir": {
        "name": "wind",
        "documentation": "instantaneous wind direction, 0-360",
        "unit": "direction",
    },
    "windgustmph": {
        "name": "windGust",
        "documentation": "max wind speed in the last 10 minutes (MPH)",
        "unit": "mph",
    },
    "windgustdir": {
        "name": "wind_gust",
        "documentation": "Wind direction at which the wind gust occurred, 0 - 360",
        "unit": "direction",
    },
    "windspeedmph": {
        "name": "wind_speed",
        "documentation": "Instantaneous wind speed",
        "unit": "mph",
    },
    "winddir_avg2m": {
        "name": "wind_speed_dir_avg_2min",
        "documentation": "Average wind direction, 2 minute average, 0-360",
        "unit": "direction",
    },
    "winddir_avg10m": {
        "name": "wind_speed_dir_avg_2min",
        "documentation": "Average wind direction, 10 minute average, 0-360",
        "unit": "direction",
    },
    "windspdmph_avg2m": {
        "name": "wind_speed_avg_2min",
        "documentation": "Average wind speed, 2 minute average",
        "unit": "mph",
    },
    "windspdmph_avg10m": {
        "name": "wind_speed_avg_10min",
        "documentation": "Average wind speed, 10 minute average",
        "unit": "mph",
    },
    "weeklyrainin": {
        "name": "rain_weekly",
        "documentation": "Weekly Rain, in",
        "unit": "Inches",
    },
    "yearlyrainin": {
        "name": "rain_yearly",
        "documentation": "Yearly Rain, in",
        "unit": "Inches",
    },
}


def generate_gauges(available_metrics, subsystem=""):
    gauges = {}
    for i in available_metrics:
        if i in ALL_GAUGES.keys():
            gauges[i] = Gauge(
                name=ALL_GAUGES[i]["name"],
                documentation=ALL_GAUGES[i]["documentation"],
                subsystem=subsystem,
                unit=ALL_GAUGES[i]["unit"],
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
