resource "aws_apigatewayv2_api" "api" {
    name = "ai-weather-api"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "api-loading-lambda" {
  api_id = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description = "links to the loading page lambda"
  integration_method = "GET"
  integration_uri = aws_lambda_function.lambda_loading_page.invoke_arn
}

resource "aws_apigatewayv2_route" "api-ai-weather" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "GET /ai-weather"
  target = "integrations/${aws_apigatewayv2_integration.api-loading-lambda.id}"
}

