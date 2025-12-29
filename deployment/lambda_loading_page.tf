data "archive_file" "lambda_loading_page" {
  type = "zip"
  source_dir = "${path.root}/../src/lambda/loading-page"
  output_path = "${path.root}/../src/lambda/loading-page/loading-page.zip"
  excludes = ["package.json", "loading-page.zip"]
}

resource "aws_lambda_function" "lambda_loading_page" {
  function_name = "ai-weather"
  role = aws_iam_role.lambda_loading_page_role.arn
  filename = "../src/lambda/loading-page/loading-page.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.lambda_loading_page.output_base64sha256
}

resource "aws_lambda_permission" "api_access" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_loading_page.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_iam_role" "lambda_loading_page_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
  description = "role with permissions for ai-weather lambda"
  name = "lambda-ai-weather-role"
}

resource "aws_iam_role_policy_attachment" "lambda_loading_page_attach_logs" {
  role = aws_iam_role.lambda_loading_page_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
