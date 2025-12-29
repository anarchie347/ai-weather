resource "aws_ssm_parameter" "gemini_api_key" {
  name = "gemini-api-key"
  type = "SecureString"
  description = "API key for Gemini"
  value = var.gemini_api_key
}