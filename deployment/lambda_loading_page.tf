resource "aws_lambda_function" "lambda_loading_page" {
  function_name = "ai-weather"
  role = aws_iam_role.lambda_assume_role.arn
  filename = "../src/lambda/loading-page/loading-page.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
}

