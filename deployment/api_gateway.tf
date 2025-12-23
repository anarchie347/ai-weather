resource "aws_apigatewayv2_api" "api" {
    name = "ai-weather-api"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "api_loading_lambda" {
  api_id = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type = "INTERNET"
  description = "links to the loading page lambda"
  integration_method = "POST"
  integration_uri = aws_lambda_function.lambda_loading_page.invoke_arn
}

resource "aws_apigatewayv2_integration" "api_ai_lambda" {
  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  description = "links to the ai fetch lambda"
  integration_method = "POST"
  integration_uri = aws_lambda_function.lambda_ai_get.invoke_arn
}

resource "aws_apigatewayv2_route" "api_ai_weather" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "GET /ai-weather"
  target = "integrations/${aws_apigatewayv2_integration.api_loading_lambda.id}"
}

resource "aws_apigatewayv2_route" "api_ai_get" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "GET /ai-get"
  target = "integrations/${aws_apigatewayv2_integration.api_ai_lambda.id}"
}

resource "aws_apigatewayv2_stage" "api_ai_weather_stage" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true
}

