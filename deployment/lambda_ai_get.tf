data "archive_file" "lambda-ai-get" {
  type = "zip"
  source_dir = "${path.root}/../src/lambda/ai_get"
  output_path = "${path.root}/../src/lambda/loading-page/ai_get.zip"
  excludes = ["package.json", "ai.zip"]
}

resource "aws_lambda_function" "lambda-ai-get" {
  function_name = "ai-get"
  role = aws_iam_role.lambda_assume_role.arn
  filename = "../src/lambda/loading-page/ai_get.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.lambda-ai-get.output_base64sha256
}

resource "aws_lambda_permission" "lambda-ai-get-api-access" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-ai-get.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}