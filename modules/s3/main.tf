variable "bucket_name" { type = string }

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
}
# 객체 소유권 설정 (ACL 허용)
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred" # ACL 사용 가능
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid    = "PublicRead"
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }
  statement {
    sid    = "EC2Write"
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    # principals {
    #   type = "AWS"
    #   identifiers = [var.ec2_role_arn]
    # }
    actions = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }
}
