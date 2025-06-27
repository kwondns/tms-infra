resource "aws_instance" "tms_backend_a" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.tms_public_subnet_c.id
  vpc_security_group_ids = [
    aws_security_group.tms_public_sg.id,
    aws_security_group.tms_ec2_sg.id
  ]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = aws_key_pair.tms_ec2_key.key_name
  tags = {
    Name   = "tms_backend_a"
    deploy = "CodeDeploy"
  }
  user_data = templatefile("${path.module}/ec2.sh", { region = var.region })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tms_ec2_profile"
  role = aws_iam_role.tms_ec2_role.name
}

resource "tls_private_key" "tms_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tms_ec2_key" {
  key_name   = "tms_ec2_key"
  public_key = tls_private_key.tms_ec2_key.public_key_openssh
}

resource "local_sensitive_file" "private_key_pem" {
  content         = tls_private_key.tms_ec2_key.private_key_pem
  filename        = "${path.module}/tms_ec2_key.pem"
  file_permission = "0600"
}

resource "aws_lb" "tms_backend_lb" {
  name               = "tms-backend-lb"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id     = aws_subnet.tms_public_subnet_c.id
    allocation_id = aws_eip.tms_nlb_eip.id
  }
  tags = {
    Name = "tms-nlb"
  }
  security_groups = [aws_security_group.tms_lb_sg.id]
}

resource "aws_lb_target_group" "tms_be_tg" {
  name     = "tms-backend-tg"
  port     = 5440
  protocol = "TCP"
  vpc_id   = aws_vpc.tms_vpc.id
  health_check {
    protocol            = "TCP"
    port                = "5440"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  preserve_client_ip = true
}

resource "aws_lb_target_group" "tms_ssh_tg" {
  name     = "tms-backend-ssh-tg"
  port     = 9981
  protocol = "TCP"
  vpc_id   = aws_vpc.tms_vpc.id
  health_check {
    protocol            = "TCP"
    port                = "9981"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  preserve_client_ip = true
}

resource "aws_lb_target_group" "tms_rds_tg" {
  name_prefix = "tms-tg"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = aws_vpc.tms_vpc.id
  target_type = "ip"
  tags = {
    Name = "tms-rds-tg"
  }

  health_check {
    protocol            = "TCP"
    port                = "5432"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "tms_https" {
  load_balancer_arn = aws_lb.tms_backend_lb.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.tms_cert_arn
  depends_on = [var.tms_cert]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tms_be_tg.arn
  }
}

resource "aws_lb_listener" "tms_ssh" {
  load_balancer_arn = aws_lb.tms_backend_lb.arn
  port              = "9981"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tms_ssh_tg.arn
  }
}

resource "aws_lb_listener" "tms_rds" {
  load_balancer_arn = aws_lb.tms_backend_lb.arn
  port              = "5432"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tms_rds_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tms_tg_attach" {
  target_group_arn = aws_lb_target_group.tms_be_tg.arn
  target_id        = aws_instance.tms_backend_a.id
  port             = 5440
}

resource "aws_lb_target_group_attachment" "tms_tg_ssh_attach" {
  target_group_arn = aws_lb_target_group.tms_ssh_tg.arn
  target_id        = aws_instance.tms_backend_a.id
  port             = 9981
}

# RDS IP 주소를 얻기 위한 데이터 소스
data "dns_a_record_set" "rds_ip" {
  host = aws_db_instance.tms_db.address
}

resource "aws_lb_target_group_attachment" "tms_rds_attach" {
  target_group_arn = aws_lb_target_group.tms_rds_tg.arn
  target_id        = data.dns_a_record_set.rds_ip.addrs[0]
  port             = 5432
}

resource "aws_route53_record" "api_tms" {
  zone_id = var.tms_route53_zone
  name    = "api.kwondns.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.tms_nlb_eip.public_ip]
}
