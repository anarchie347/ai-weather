export async function handler(event) {
  console.log("TESTING");
  const response = {
    statusCode: 200,
    headers: {
      "Content-Type": "text/html",
    },
    body: html,
  };
  return response;
}
