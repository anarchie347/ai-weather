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

// ROLES

resource "aws_iam_role" "lambda_assume_role" {
  name = "lambda_assume_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
}



// Lambda logging

resource "aws_iam_role_policy_attachment" "lambda-logs-attachment" {
  role = aws_iam_role.lambda_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}