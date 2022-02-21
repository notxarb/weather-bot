import os
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler
import requests
import json

app = App(token=os.environ.get("SLACK_BOT_TOKEN"))
accuweather_api_key = os.environ.get("ACCUWEATHER_API_KEY")

@app.command("/weather")
def get_weather(ack, respond, command):
    ack()
    respond(f"looking up weather for {command['text']}...")
    # Look up the location from accuweather
    location_url = f"http://dataservice.accuweather.com/locations/v1/postalcodes/search?apikey={accuweather_api_key}&q={command['text']}"
    location_response = requests.get(location_url)
    location_data = json.loads(location_response.text)
    # Look up the weather for the location
    weather_url = f"http://dataservice.accuweather.com/currentconditions/v1/{location_data[0]['Key']}?apikey={accuweather_api_key}"
    weather_response = requests.get(weather_url)
    weather_data = json.loads(weather_response.text)
    respond(f"weather for {location_data[0]['LocalizedName']}, {location_data[0]['AdministrativeArea']['LocalizedName']}: {weather_data[0]['WeatherText']} {weather_data[0]['Temperature']['Imperial']['Value']}{weather_data[0]['Temperature']['Imperial']['Unit']}")
    if 'RateLimit-Remaining' in weather_response.headers.keys():
        respond(f"accuweather api requests remaining {weather_response.headers['RateLimit-Remaining']}/{weather_response.headers['RateLimit-Limit']}")

if __name__ == "__main__":
    SocketModeHandler(app, os.environ["SLACK_APP_TOKEN"]).start()


