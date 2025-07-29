resource "aws_lambda_function" "timeline_chatbot" {
  function_name = "timeline-chatbot-api"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.timeline_chatbot_repo.repository_url}:latest"
  timeout       = 300
  memory_size   = 1769
  publish       = true

  environment {
    variables = {
      DB_DATABASE         = var.db_name
      DB_USER             = var.db_username
      DB_PASSWORD         = var.db_password
      DB_HOST             = var.db_host
      DB_PORT             = var.db_port
      DB_SCHEMA           = var.db_chatbot_schema
      ENVIRONMENT         = "production"
      OPENAI_API_KEY      = var.openai_api_key
      S3_BUCKET           = aws_s3_bucket.timeline_time_weighted_vector_store_bucket.bucket
      S3_KEY              = "time_weighted_memory_stream"
      AWS_LWA_INVOKE_MODE = "RESPONSE_STREAM"
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

resource "aws_lambda_function_url" "chatbot_lambda_function_url" {
  authorization_type = "NONE"
  function_name      = aws_lambda_function.timeline_chatbot.function_name
  invoke_mode        = "RESPONSE_STREAM"

  cors {
    allow_credentials = false
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_lambda_permission" "chatbot_function_url_public" {
  statement_id  = "AllowPublicInvokeViaFunctionURL"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.timeline_chatbot.function_name
  principal     = "*"                            # 모든 호출자 허용
  function_url_auth_type = "NONE"
}
