import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { GetParameterCommand, SSMClient } from "@aws-sdk/client-ssm";
import { GoogleGenAI } from "@google/genai";
import { encode } from "@toon-format/toon";
import { fetchWeatherApi } from "openmeteo";

const ssmClient = new SSMClient({});
const geminiFetchCmd = new GetParameterCommand({
  Name: "gemini-api-key",
  WithDecryption: true,
});

const s3Client = new S3Client({});

const geminiApiKey = (await ssmClient.send(geminiFetchCmd)).Parameter.Value;

const ai = new GoogleGenAI({ apiKey: geminiApiKey });

const PREPROMPTv1 = `respond with just plaintext html/css/js (one file) of a webpage to graphically display the data at the end of this prompt.

The webpage should make heavy use of css and look like a sleek, modern weather app, however it requires no functionality beyond displaying this data. It does not need a search bar, or any interactivity beyond aesthetics.
The website should work properly with both mobile and desktop and all browsers and have some unique flair meaning if this prompt is used again the result will be drastically different. The design does not have to be adaptable to different sets of weather data, it is only going to be used with the data provided, so incorporate the weather data into the styling, not just displaying the information in a standard format`;

export async function handler(args) {
  const { lat, long, s3Key } = args;
  const wd = await getWeatherData(lat, long);
  formatWeatherObj(wd);
  const wdStr = encode(wd);

  const ai_resp = await ai.models.generateContent({
    model: "gemini-2.5-flash",
    contents: wdStr,
    config: { systemInstruction: PREPROMPTv1 },
  });

  const html = ai_resp.text;
  console.log(html);

  const storeToS3Cmd = new PutObjectCommand({
    Bucket: process.env.PAGESTORE_BUCKET,
    Key: s3Key,
    Body: html,
  });
}

function formatWeatherObj(weatherData) {
  for (let prop in weatherData.hourly) {
    if (prop != "time") {
      weatherData.hourly[prop] = Object.values(weatherData.hourly[prop]);
    }
  }
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
