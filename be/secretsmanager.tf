resource "aws_secretsmanager_secret" "tms_secret" {
  name = "tms-secret"
}

resource "aws_secretsmanager_secret_version" "tms_secret_version" {
  secret_id = aws_secretsmanager_secret.tms_secret.id
  secret_string = jsonencode({
    db_host                   = split(":", aws_db_instance.tms_db.endpoint)[0]
    db_username               = var.db_username
    username                  = var.username
    password                  = var.db_password
    db_password               = var.db_password
    db_port                   = var.db_port
    db_name                   = var.db_name
    access_secret_key         = var.access_secret_key
    access_expire             = var.access_expire
    refresh_secret_key        = var.refresh_secret_key
    refresh_expire            = var.refresh_expire
    s3_env                    = var.env
    s3_secret_key             = var.s3_secret_key
    s3_access_key             = var.s3_access_key
    db_ssl_path               = var.db_ssl_path
    file_destroy_delay        = var.file_destroy_delay
    reset_password_secret_key = var.reset_password_secret_key
    reset_password_expire     = var.reset_password_expire
    mail_user                 = var.mail_user
    mail_password             = var.mail_password
    elasticache_host          = var.elasticache_host
    elasticache_port          = var.elasticache_port
    s3_tmp_archive_bucket     = var.s3_tmp_archive_bucket
    front_url                 = var.front_url
    chatbot_url               = aws_lambda_function_url.chatbot_lambda_function_url.function_url

    # google_client_id     = var.google_client_id
    # google_client_secret = var.google_client_secret
    # google_redirect_uri  = var.google_redirect_uri
    #
    # kakao_client_id    = var.kakao_client_id
    # kakao_redirect_uri = var.kakao_redirect_uri
    #
    # naver_client_id     = var.naver_client_id
    # naver_redirect_uri  = var.naver_redirect_uri
    # naver_client_secret = var.naver_client_secret
    #
  })
}

# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id              = aws_vpc.tms_vpc.id
#   service_name        = "com.amazonaws.${var.region}.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true
#   subnet_ids = [
#     aws_subnet.tms_private_subnet_a.id,
#     aws_subnet.tms_private_subnet_c.id
#   ]
#   security_group_ids = [aws_security_group.tms_vpc_endpoint_sg.id]
# }
