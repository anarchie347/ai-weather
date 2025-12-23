data "archive_file" "lambda_ai_get" {
  type = "zip"
  source_dir = "${path.root}/../src/lambda/ai-get"
  output_path = "${path.root}/../src/lambda/ai-get/ai-get.zip"
  excludes = ["package.json", "ai.zip"]
}

resource "aws_lambda_function" "lambda_ai_get" {
  function_name = "ai-get"
  role = aws_iam_role.lambda_assume_role.arn
  filename = "../src/lambda/ai-get/ai-get.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.lambda_ai_get.output_base64sha256
}

resource "aws_lambda_permission" "lambda_ai_get_api_access" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_ai_get.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}