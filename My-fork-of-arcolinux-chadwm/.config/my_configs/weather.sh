#!/bin/bash

# Closebox73
# This script is to get weather data from openweathermap.com in the form of a json file
# so that conky will still display the weather when offline even though it doesn't up to date

# you can use this or replace with yours
api_key=8e5ce2954f56c6d2cf3cfd5f0c4cdabc

# Location: Allenstown, NH 03275
zip_code="03275,US"
# Alternative: query by coordinates instead of ZIP (swap the url line below)
# lat=43.1567
# lon=-71.4048

url="api.openweathermap.org/data/2.5/weather?zip=${zip_code}&appid=${api_key}&units=metric&lang=en"
# url="api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${api_key}&units=metric&lang=en"
curl "${url}" -s -o ~/.cache/weather.json
