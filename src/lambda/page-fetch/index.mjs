import { GetObjectCommand, NoSuchKey, S3Client } from "@aws-sdk/client-s3";

const s3Client = new S3Client({});

export async function handler(event) {
  const id = Number.parseFloat(event.queryStringParameters.id).toString(); //validation on input

  try {
    const fetchCmd = new GetObjectCommand({
      Bucket: process.env.PAGESTORE_BUCKET,
      Key: id,
    });
    const resp = await s3Client.send(fetchCmd);
    const str = await resp.Body.transformToString();
    console.log("SUCCESS");
    const response = {
      statusCode: 200,
      headers: {
        "Content-Type": "text/html",
      },
      body: str,
    };
    return response;
  } catch (ex) {
    if (ex instanceof NoSuchKey) {
      // return some html
      console.log("NOKEY");
      const response = {
        statusCode: 204,
        headers: {
          "Content-Type": "text/html",
        },
        body: waitingHTML,
      };
      return response;
    }
    console.log("OTHER PROBLM");
  }
}

const waitingHTML = `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Ai Weather</title>
  </head>
  <body>
    <div id="fetching-container" hidden>
      <h1>Generating...</h1>
    </div>
  </body>
</html>
`;
