resource "aws_ssm_parameter" "gemini_api_key" {
  name = "gemini-api-key"
  type = "SecureString"
  value = var.gemini_api_key
}