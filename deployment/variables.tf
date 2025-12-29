variable "gemini_api_key" {
  type = string
  sensitive = true
  ephemeral = true
  description = "API key for gemini"
}