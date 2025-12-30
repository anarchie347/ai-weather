data "archive_file" "lambda_page_fetch" {
  type = "zip"
  source_dir = "${path.root}/../src/lambda/page-fetch"
  output_path = "${path.root}/../src/lambda/page-fetch/page-fetch.zip"
  excludes = ["package.json", "page-fetch.zip"]
}

resource "aws_lambda_function" "lambda_page_fetch" {
  function_name = "page-fetch"
  role = aws_iam_role.lambda_page_fetch_role.arn
  filename = "${path.root}/../src/lambda/page-fetch/page-fetch.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.lambda_page_fetch.output_base64sha256
  environment {
    variables = {
      PAGESTORE_BUCKET = aws_s3_bucket.pagestore.bucket
    }
  }
}

resource "aws_lambda_permission" "lambda_page_fetch_api_access" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_page_fetch.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_iam_role" "lambda_page_fetch_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
  description = "role with permissions for page-fetch lambda"
  name = "lambda-page-fetch-role"
}

resource "aws_iam_role_policy_attachment" "lambda_page_fetch_attach_logs" {
  role = aws_iam_role.lambda_page_fetch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_page_fetch_attach_pagestore_get" {
  role = aws_iam_role.lambda_page_fetch_role.name
  policy_arn = aws_iam_policy.pagestore_get_policy.arn
}