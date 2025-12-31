import { InvokeCommand, LambdaClient } from "@aws-sdk/client-lambda";

const lambdaClient = new LambdaClient({});

export async function handler(event) {
  const lat = Number.parseInt(event.queryStringParameters.lat);
  const long = Number.parseInt(event.queryStringParameters.long);
  const s3Key = (Date.now() + Math.random()).toString();

  const invokeCmd = new InvokeCommand({
    FunctionName: process.env.WORKER_FUNC_NAME,
    InvocationType: "Event",
    Payload: {
      lat,
      long,
      s3Key,
    },
  });
  await lambdaClient.send(invokeCmd);
  const response = {
    statusCode: 202,
    jobId: s3Key,
  };
  return response;
}
