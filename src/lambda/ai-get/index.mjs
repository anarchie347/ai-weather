import fs from "node:fs";
import { fetchWeatherApi } from "openmeteo";

const html = fs.readFileSync("index.html", "utf-8");

export async function handler(event) {
  const lat = 52.52;
  const long = 13.41;
  const wd = await getWeatherData(lat, long);
  const formattedWd = tmpFormatData(wd);
  const substitutedHTML = html.replace("$$WEATHER_DATA$$", formattedWd);
  await new Promise((res) => setTimeout(res, 1000));
  const response = {
    statusCode: 200,
    headers: {
      "Content-Type": "text/html",
    },
    body: substitutedHTML,
  };
  return response;
}

function tmpFormatData(weatherData) {
  return `<pre>${JSON.stringify(weatherData, null, 2)}</pre>`;
}

async function getWeatherData(lat, long) {
  const params = {
    latitude: lat,
    longitude: long,
    hourly: [
      "temperature_2m",
      "apparent_temperature",
      "precipitation",
      "weather_code",
      "cloud_cover",
      "wind_speed_10m",
      "temperature_80m",
    ],
    forecast_days: 3,
  };
  const url = "https://api.open-meteo.com/v1/forecast";
  const responses = await fetchWeatherApi(url, params);

  // Process first location. Add a for-loop for multiple locations or weather models
  const response = responses[0];

  // Attributes for timezone and location
  const latitude = response.latitude();
  const longitude = response.longitude();
  const elevation = response.elevation();
  const utcOffsetSeconds = response.utcOffsetSeconds();

  const hourly = response.hourly();

  // Note: The order of weather variables in the URL query and the indices below need to match!
  return {
    hourly: {
      time: Array.from(
        {
          length:
            (Number(hourly.timeEnd()) - Number(hourly.time())) /
            hourly.interval(),
        },
        (_, i) =>
          new Date(
            (Number(hourly.time()) + i * hourly.interval() + utcOffsetSeconds) *
              1000
          )
      ),
      temperature_2m: hourly.variables(0).valuesArray(),
      apparent_temperature: hourly.variables(1).valuesArray(),
      precipitation: hourly.variables(2).valuesArray(),
      weather_code: hourly.variables(3).valuesArray(),
      cloud_cover: hourly.variables(4).valuesArray(),
      wind_speed_10m: hourly.variables(5).valuesArray(),
      temperature_80m: hourly.variables(6).valuesArray(),
    },
  };
}
