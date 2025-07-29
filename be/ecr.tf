# ECR 리포지토리 생성
resource "aws_ecr_repository" "timeline_chatbot_repo" {
  name                 = "${var.project}-timeline-chatbot"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.project}-timeline-chatbot-ecr"
  }
}
