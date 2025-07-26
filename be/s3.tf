module "s3_drive_user_profile" {
  source       = "../modules/s3"
  bucket_name  = "tms-drive-user-profile"
}

module "s3_drive_user" {
  source       = "../modules/s3"
  bucket_name  = "tms-drive-user"
}

module "s3_drive_public" {
  source       = "../modules/s3"
  bucket_name  = "tms-drive-public"
}

module "s3_leisure" {
  source = "../modules/s3"
  bucket_name = "tms-leisure"
}

module "s3_blog" {
  source       = "../modules/s3"
  bucket_name  = "tms-blog"
}

module "s3_portfolio" {
  source       = "../modules/s3"
  bucket_name  = "tms-portfolio"
}

module "s3_timeline" {
  source       = "../modules/s3"
  bucket_name  = "tms-timeline"
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.project}-server-artifacts"
  force_destroy = true

  tags = {
    Name = "${var.project}-server-artifacts"
  }
}

resource "aws_s3_bucket" "timeline-chatbot-artifact_bucket" {
  bucket        = "${var.project}-timeline-chatbot-artifacts"
  force_destroy = true

  tags = {
    Name = "${var.project}-timeline-chatbot-artifacts"
  }
}

resource "aws_s3_bucket" "timeline_time_weighted_vector_store_bucket" {
  bucket = "timeline-time-weighted-vector-store-memory"
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "tms_archive_temp" {
  bucket = "tms-archive-${random_id.bucket_suffix.hex}"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Environment = "production"
    Service     = "compression-service"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "compressed_lifecycle" {
  bucket = aws_s3_bucket.tms_archive_temp.id

  rule {
    id = "auto-delete"
    expiration {
      days = 0
    }
    filter {
      prefix = "temp-download/"
    }
    status = "Enabled"
  }
}
