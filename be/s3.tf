module "s3_blog" {
  source       = "../modules/s3"
  bucket_name  = "tms-blog"
  ec2_role_arn = aws_iam_role.tms_ec2_role.arn
}

module "s3_portfolio" {
  source       = "../modules/s3"
  bucket_name  = "tms-portfolio"
  ec2_role_arn = aws_iam_role.tms_ec2_role.arn
}

module "s3_timeline" {
  source       = "../modules/s3"
  bucket_name  = "tms-timeline"
  ec2_role_arn = aws_iam_role.tms_ec2_role.arn
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.project}-server-artifacts"
  force_destroy = true

  tags = {
    Name = "${var.project}-server-artifacts"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# resource "aws_s3_bucket" "tms_archive_temp" {
#   bucket = "tms-archive-${random_id.bucket_suffix.hex}"
#
#   lifecycle {
#     prevent_destroy = false
#   }
#
#   tags = {
#     Environment = "production"
#     Service     = "compression-service"
#   }
# }
#
# resource "aws_s3_bucket_lifecycle_configuration" "compressed_lifecycle" {
#   bucket = aws_s3_bucket.tms_archive_temp.id
#
#   rule {
#     id = "auto-delete"
#     expiration {
#       days = 0
#     }
#     filter {
#       prefix = "temp-download/"
#     }
#     status = "Enabled"
#   }
# }
