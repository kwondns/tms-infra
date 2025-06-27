resource "aws_db_instance" "tms_db" {
  identifier           = "tms"
  engine               = "postgres"
  engine_version       = "17.4"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = "tms"
  port                 = var.db_port
  db_name              = "tms"
  password             = var.db_password
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.tms_db_subnet.name
  vpc_security_group_ids = [aws_security_group.tms_rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
}

resource "aws_db_subnet_group" "tms_db_subnet" {
  name = "tms_db_subnet"
  subnet_ids = [
    aws_subnet.tms_public_subnet_a.id,
    aws_subnet.tms_public_subnet_c.id
  ]
}

# # RDS Proxy
# resource "aws_db_proxy" "tms_db_proxy" {
#   name          = "tms"
#   engine_family = "POSTGRESQL"
#   role_arn      = aws_iam_role.tms_rds_proxy_role.arn
#   vpc_subnet_ids = [aws_subnet.tms_private_subnet_a.id, aws_subnet.tms_private_subnet_c.id]
#   vpc_security_group_ids = [aws_security_group.tms_private_proxy_sg.id]
#   auth {
#     auth_scheme = "SECRETS"
#     secret_arn  = aws_secretsmanager_secret.tms_secret.arn
#     iam_auth    = "DISABLED"
#   }
#   require_tls = true
# }
#
# # Proxy와 RDS 연결
# resource "aws_db_proxy_default_target_group" "tms_db_proxy_target" {
#   db_proxy_name = aws_db_proxy.tms_db_proxy.name
#   connection_pool_config {
#     max_connections_percent   = 100
#     connection_borrow_timeout = 120
#   }
# }
#
# resource "aws_db_proxy_target" "tms_db_proxy_target" {
#   db_proxy_name          = aws_db_proxy.tms_db_proxy.name
#   target_group_name      = "default"
#   db_instance_identifier = aws_db_instance.tms_db.identifier
# }
