import { InvokeCommand, LambdaClient } from "@aws-sdk/client-lambda";

const lambdaClient = new LambdaClient({});

export async function handler(event) {
  const lat = Number.parseFloat(event.queryStringParameters.lat);
  const long = Number.parseFloat(event.queryStringParameters.long);
  const placeName = event.queryStringParameters.placeName;
  const s3Key = (Date.now() + Math.random()).toString();

  const invokeCmd = new InvokeCommand({
    FunctionName: process.env.WORKER_FUNC_NAME,
    InvocationType: "Event",
    Payload: JSON.stringify({
      lat,
      long,
      s3Key,
      placeName,
    }),
  });
  await lambdaClient.send(invokeCmd);
  const response = {
    statusCode: 202,
    headers: {
      location: `${process.env.PAGE_FETCH_ENDPOINT}?id=${s3Key}`,
    },
  };
  return response;
}
