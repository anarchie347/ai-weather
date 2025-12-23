import fs from "node:fs";

const html = fs.readFileSync("index.html", "utf-8");

export async function handler(event) {
  await new Promise((res) => setTimeout(res, 2000));
  const response = {
    statusCode: 200,
    headers: {
      "Content-Type": "text/html",
    },
    body: html,
  };
  return response;
}
