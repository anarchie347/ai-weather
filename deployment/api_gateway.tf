resource "aws_apigatewayv2_api" "api" {
    name = "ai-weather-api"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "api-loading-lambda" {
  api_id = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type = "INTERNET"
  description = "links to the loading page lambda"
  integration_method = "POST"
  integration_uri = aws_lambda_function.lambda_loading_page.invoke_arn
}

resource "aws_apigatewayv2_integration" "api-ai-lambda" {
  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  description = "links to the ai fetch lambda"
  integration_method = "POST"
  integration_uri = aws_lambda_function.lambda-ai-get.invoke_arn
}

resource "aws_apigatewayv2_route" "api-ai-weather" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "GET /ai-weather"
  target = "integrations/${aws_apigatewayv2_integration.api-loading-lambda.id}"
}

resource "aws_apigatewayv2_route" "api-ai-get" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "GET /ai-get"
  target = "integrations/${aws_apigatewayv2_integration.api-ai-lambda.id}"
}

resource "aws_apigatewayv2_stage" "api-ai-weather-stage" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true
}

