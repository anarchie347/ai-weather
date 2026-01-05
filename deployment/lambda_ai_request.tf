data "archive_file" "lambda_ai_request" {
  type = "zip"
  source_dir = "${path.root}/../src/lambda/ai-request"
  output_path = "${path.root}/../src/lambda/ai-request/ai-request.zip"
  excludes = ["package.json", "ai-request.zip"]
}

resource "aws_lambda_function" "lambda_ai_request" {
  function_name = "ai-request"
  role = aws_iam_role.lambda_ai_request_role.arn
  filename = "${path.root}/../src/lambda/ai-request/ai-request.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.lambda_ai_request.output_base64sha256
  timeout = 5

  environment {
    variables = {
        WORKER_FUNC_NAME = aws_lambda_function.lambda_ai_get.function_name
    }
  }
}

resource "aws_lambda_permission" "lambda_ai_request_api_access" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_ai_request.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_iam_role" "lambda_ai_request_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
  description = "Role with permissions for ai-request"
  name = "lambda-ai-request-role"
}

resource "aws_iam_role_policy_attachment" "lambda_ai_request_attach_logs" {
  role = aws_iam_role.lambda_ai_request_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ai_request_attach_invoke" {
  role = aws_iam_role.lambda_ai_request_role.name
  policy_arn = aws_iam_policy.ai_get_invoke_policy.arn
}