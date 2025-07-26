resource "aws_api_gateway_rest_api" "chatbot_api" {
  name        = "timeline-chatbot-api"
  description = "Timeline Chatbot API"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "chatbot_resource" {
  parent_id   = aws_api_gateway_rest_api.chatbot_api.root_resource_id
  path_part   = "chat"
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
}

resource "aws_api_gateway_method" "chatbot_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.chatbot_resource.id
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
}

resource "aws_api_gateway_integration" "chatbot_lambda_integration" {
  http_method = aws_api_gateway_method.chatbot_post.http_method
  resource_id = aws_api_gateway_resource.chatbot_resource.id
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  type        = "AWS_PROXY"

  integration_http_method = "POST"
  uri                     = aws_lambda_function.timeline_chatbot.invoke_arn
}

resource "aws_api_gateway_resource" "chatbot_embedding_resource" {
  parent_id   = aws_api_gateway_rest_api.chatbot_api.root_resource_id
  path_part   = "embedding"
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
}

resource "aws_api_gateway_method" "chatbot_embedding_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.chatbot_embedding_resource.id
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
}

resource "aws_api_gateway_integration" "chatbot_embedding_lambda_integration" {
  http_method = aws_api_gateway_method.chatbot_embedding_post.http_method
  resource_id = aws_api_gateway_resource.chatbot_embedding_resource.id
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  type        = "AWS_PROXY"

  integration_http_method = "POST"
  uri                     = aws_lambda_function.timeline_chatbot.invoke_arn
}


resource "aws_api_gateway_deployment" "chatbot_deployment" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  depends_on = [aws_api_gateway_integration.chatbot_lambda_integration]
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.chatbot_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "chatbot_api_stage"{
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  deployment_id = aws_api_gateway_deployment.chatbot_deployment.id
  stage_name = "prod"
}

resource "aws_api_gateway_base_path_mapping" "chatbot_mapping" {
  domain_name = aws_api_gateway_domain_name.chat_bot_domain.domain_name
  api_id      = aws_api_gateway_rest_api.chatbot_api.id
  stage_name  = aws_api_gateway_stage.chatbot_api_stage.stage_name
  base_path = ""
}

resource "aws_api_gateway_domain_name" "chat_bot_domain" {
  domain_name     = "chat-api.kwondns.com"
  certificate_arn = var.tms_cert_wildcard_arn
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_route53_record" "chat_api_tms" {
  zone_id = var.tms_route53_zone
  name    = "chat-api.kwondns.com"
  type    = "A"
  alias {
    name                   = aws_api_gateway_domain_name.chat_bot_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.chat_bot_domain.cloudfront_zone_id
    evaluate_target_health = false
  }
}
