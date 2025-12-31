data "archive_file" "lambda_ai_get" {
  type = "zip"
  source_dir = "${path.root}/../src/lambda/ai-get"
  output_path = "${path.root}/../src/lambda/ai-get/ai-get.zip"
  excludes = ["package.json", "ai-get.zip"]
}

resource "aws_lambda_function" "lambda_ai_get" {
  function_name = "ai-get"
  role = aws_iam_role.lambda_ai_get_role.arn
  filename = "${path.root}/../src/lambda/ai-get/ai-get.zip"
  runtime = "nodejs22.x"
  handler = "index.handler"
  source_code_hash = data.archive_file.lambda_ai_get.output_base64sha256
  timeout = 180

  environment {
    variables = {
      PAGESTORE_BUCKET = aws_s3_bucket.pagestore.bucket
    }
  }
}

resource "aws_iam_role" "lambda_ai_get_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
  description = "Role with permissions for ai-get"
  name = "lambda-ai-get-role"
}

resource "aws_iam_role_policy_attachment" "lambda_ai_get_attach_logs" {
  role = aws_iam_role.lambda_ai_get_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ai_get_attach_gemini_key" {
  role = aws_iam_role.lambda_ai_get_role.name
  policy_arn = aws_iam_policy.gemini_api_key_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_ai_get_attach_pagestore_put" {
  role = aws_iam_role.lambda_ai_get_role.name
  policy_arn = aws_iam_policy.pagestore_put_policy.arn
}