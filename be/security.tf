# SG 본체는 참조 없이 생성
resource "aws_security_group" "tms_public_sg" {
  vpc_id      = aws_vpc.tms_vpc.id
  name        = "tms_public_sg"
  description = "tms Backend SG"
}

resource "aws_security_group" "tms_ec2_sg" {
  vpc_id = aws_vpc.tms_vpc.id
  name   = "tms_ec2_sg"

  ingress {
    from_port = 5440
    to_port   = 5440
    protocol  = "tcp"
    security_groups = [aws_security_group.tms_lb_sg.id]
  }
}

resource "aws_security_group" "tms_lb_sg" {
  vpc_id = aws_vpc.tms_vpc.id
  name   = "tms_lb_sg"
}

# LB SG 인바운드 규칙 (퍼블릭)
resource "aws_security_group_rule" "lb_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tms_lb_sg.id
}

resource "aws_security_group_rule" "lb_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tms_lb_sg.id
}

# LB SG 아웃바운드 규칙 (EC2 SG로)
resource "aws_security_group_rule" "lb_to_ec2_out" {
  type                     = "egress"
  from_port                = 5440
  to_port                  = 5440
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.tms_public_sg.id
  security_group_id        = aws_security_group.tms_lb_sg.id
}

# EC2 SG 인바운드 SSH 규칙
resource "aws_security_group_rule" "ec2_from_ssh_in" {
  type              = "ingress"
  from_port         = 9981
  to_port           = 9981
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tms_public_sg.id
}

# EC2 SG 아웃바운드 규칙 (전체 허용)
resource "aws_security_group_rule" "ec2_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tms_public_sg.id
}

resource "aws_security_group" "tms_vpc_endpoint_sg" {
  vpc_id = aws_vpc.tms_vpc.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [aws_security_group.tms_public_sg.id]  # EC2의 SG 허용
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tms_rds_sg" {
  name        = "tms_rds_sg"
  description = "RDS SG"
  vpc_id      = aws_vpc.tms_vpc.id
  ingress {
    from_port = var.db_port
    to_port   = var.db_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_security_group" "tms_private_rds_sg" {
#   name        = "tms_private_rds_sg"
#   description = "RDS SG"
#   vpc_id      = aws_vpc.tms_vpc.id
#   # ingress {
#   #   from_port = 5432
#   #   to_port = 5432
#   #   protocol = "tcp"
#   #   cidr_blocks = ["0.0.0.0/0"]
#   # }
#   ingress {
#     from_port = var.db_port
#     to_port   = var.db_port
#     protocol  = "tcp"
#     security_groups = [aws_security_group.tms_private_proxy_sg.id]
#   }
#
#   egress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# resource "aws_security_group" "tms_private_proxy_sg" {
#   name        = "tms_private_proxy_sg"
#   description = "Proxy SG"
#   vpc_id      = aws_vpc.tms_vpc.id
#   ingress {
#     from_port = var.db_port
#     to_port   = var.db_port
#     protocol  = "tcp"
#     security_groups = [aws_security_group.tms_public_sg.id]
#   }
#
#   egress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# resource "aws_security_group" "tms_private_elasticache_sg" {
#   name        = "tms_private_elasticache_sg"
#   description = "ElastiCache SG"
#   vpc_id      = aws_vpc.tms_vpc.id
#   ingress {
#     from_port = var.elasticache_port
#     to_port   = var.elasticache_port
#     protocol  = "tcp"
#     security_groups = [aws_security_group.tms_ec2_sg.id]
#   }
#
#   egress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

