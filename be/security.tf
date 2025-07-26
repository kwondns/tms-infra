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
    # cidr_blocks       = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tms_lb_sg.id]
  }

  ingress {
    from_port = 443
    to_port   = 9981
    protocol  = "tcp"
    # cidr_blocks       = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tms_lb_sg.id]
  }
  # ingress {
  #   from_port = 0
  #   to_port = 0
  #   cidr_blocks = ["0.0.0.0/0"]
  #   protocol = "-1"
  # }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tms_lb_sg" {
  vpc_id      = aws_vpc.tms_vpc.id
  name_prefix = "tms-lb-sg"
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 9981
    to_port   = 9981
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    security_groups = [aws_security_group.tms_lb_sg.id, aws_security_group.tms_ec2_sg.id, aws_security_group.lambda_sg.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "tms_rds_tmp_sg" {
  name_prefix        = "tms-rds-sg"
  description = "RDS SG"
  vpc_id      = aws_vpc.tms_vpc.id
  ingress {
    from_port = var.db_port
    to_port   = var.db_port
    protocol  = "tcp"
    security_groups = [aws_security_group.tms_lb_sg.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lambda_sg" {
  name_prefix = "timeline-chatbot-lambda-"
  vpc_id      = aws_vpc.tms_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "timeline-chatbot-lambda-sg"
  }
}

resource "aws_security_group" "efs_sg" {
  name_prefix = "timeline-chatbot-efs-"
  vpc_id      = aws_vpc.tms_vpc.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "timeline-chatbot-efs-sg"
  }
}
