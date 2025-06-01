# resource "aws_elasticache_subnet_group" "tms_valkey" {
#   name = "tms"
#   subnet_ids = [aws_subnet.tms_private_subnet_a.id]
# }
#
# resource "aws_elasticache_replication_group" "tms_valkey" {
#   replication_group_id = "tms"
#   engine = "valkey"
#   engine_version = "8.0"
#   node_type = "cache.t4g.micro"
#   num_cache_clusters = 1
#   port = var.elasticache_port
#   parameter_group_name = "default.valkey8"
#   subnet_group_name = aws_elasticache_subnet_group.tms_valkey.name
#   security_group_ids = [aws_security_group.tms_private_elasticache_sg.id]
#   transit_encryption_enabled = true
#   auth_token = random_password.elasticache_auth_token.result
#   automatic_failover_enabled = false
#   multi_az_enabled = false
#   description = "tms_valkey"
# }
#
# resource "random_password" "elasticache_auth_token" {
#   length           = 32
#   special          = true
#   override_special = "!&#$^<>-"
# }
