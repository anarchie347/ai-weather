data "archive_file" "lambda_loading_page" {
  type = "zip"
  source_dir = "${path.root}/../src/lambda/loading-page"
  output_path = "${path.root}/../src/lambda/loading-page/loading-page.zip"
  excludes = ["package.json", "loading-page.zip"]
}

resource "aws_lambda_function" "lambda_loading_page" {
  function_name = "ai-weather"
  role = aws_iam_role.lambda_assume_role.arn
  filename = "../src/lambda/loading-page/loading-page.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.lambda_loading_page.output_base64sha256
}

resource "aws_lambda_permission" "api-access" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_loading_page.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}"
}