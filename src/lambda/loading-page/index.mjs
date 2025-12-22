import fs from "node:fs";

const html = fs.readFileSync("index.html", "utf-8");

export async function handler(event) {
  const response = {
    statusCode: 200,
    headers: {
      "Content-Type": "text/html",
    },
    body: html,
  };
  return response;
}
