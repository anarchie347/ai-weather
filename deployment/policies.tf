// POLICY DOCUMENTS

data "aws_iam_policy_document" "lambda_assume_role_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "gemini_api_key_access_policy_doc" {
  statement {
    actions = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.gemini_api_key.arn]
  }
}

// POLICIES

resource "aws_iam_policy" "gemini_api_key_access_policy" {
  name = "gemini-api-key-access"
  description = "grants access to read the gemnini api key from SSM Parameterstore"
  policy = data.aws_iam_policy_document.gemini_api_key_access_policy_doc.json
  
}