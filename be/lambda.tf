resource "aws_lambda_function" "timeline_chatbot" {
  function_name = "timeline-chatbot-api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.11"
  timeout       = 300
  memory_size   = 1769
  publish       = true

  layers = [
    aws_lambda_layer_version.chatbot_layer_db.arn, aws_lambda_layer_version.chatbot_layer_langchain.arn,
    aws_lambda_layer_version.chatbot_layer_lm.arn, aws_lambda_layer_version.chatbot_layer_lark.arn,
    "arn:aws:lambda:ap-northeast-2:032012114076:layer:postgresql-libpq-ssl:1",
  ]

  s3_bucket = aws_s3_bucket.timeline-chatbot-artifact_bucket.bucket
  s3_key    = "source_output.zip"

  environment {
    variables = {
      DB_DATABASE    = var.db_name
      DB_USER        = var.db_username
      DB_PASSWORD    = var.db_password
      DB_HOST        = var.db_host
      DB_PORT        = var.db_port
      DB_SCHEMA      = var.db_chatbot_schema
      ENVIRONMENT    = "production"
      OPENAI_API_KEY = var.openai_api_key
      S3_BUCKET      = aws_s3_bucket.timeline_time_weighted_vector_store_bucket.bucket
      S3_KEY         = "time_weighted_memory_stream"
    }
  }

  depends_on = [
    aws_s3_bucket.timeline-chatbot-artifact_bucket,
  ]
}

resource "aws_lambda_layer_version" "chatbot_layer_db" {
  filename   = "${path.module}/chatbot_layer/layer-db/layer-db.zip"
  layer_name = "timeline-chatbot-db"

  compatible_runtimes = ["python3.11"]

  source_code_hash = filebase64sha256("${path.module}/chatbot_layer/layer-db/layer-db.zip")
}
resource "aws_lambda_layer_version" "chatbot_layer_langchain" {
  filename   = "${path.module}/chatbot_layer/layer-langchain/layer-langchain.zip"
  layer_name = "timeline-chatbot-langchain"

  compatible_runtimes = ["python3.11"]

  source_code_hash = filebase64sha256("${path.module}/chatbot_layer/layer-langchain/layer-langchain.zip")
}
resource "aws_lambda_layer_version" "chatbot_layer_lm" {
  filename   = "${path.module}/chatbot_layer/layer-lm/layer-lm.zip"
  layer_name = "timeline-chatbot-lm"

  compatible_runtimes = ["python3.11"]

  source_code_hash = filebase64sha256("${path.module}/chatbot_layer/layer-lm/layer-lm.zip")
}

resource "aws_lambda_layer_version" "chatbot_layer_lark" {
  filename   = "${path.module}/chatbot_layer/layer-lark/layer-lark.zip"
  layer_name = "timeline-chatbot-lark"

  compatible_runtimes = ["python3.11"]

  source_code_hash = filebase64sha256("${path.module}/chatbot_layer/layer-lark/layer-lark.zip")
}

resource "aws_lambda_permission" "api_gw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.timeline_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowAPIGatewayInvoke"
  source_arn    = "${aws_api_gateway_rest_api.chatbot_api.execution_arn}/*/*"
}
