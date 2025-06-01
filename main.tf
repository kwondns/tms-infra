provider "aws" {
  region = "ap-northeast-2" # Seoul
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_route53_zone" "tms" {
  name = "kwondns.com."      # 도메인 이름 끝에 점(.) 포함 (권장)
  private_zone = false               # 퍼블릭 존일 경우 false
}

module "be" {
  source           = "./be"
  project          = var.project
  instance_type    = var.instance_type
  instance_ami     = var.instance_ami
  env              = var.env
  region           = var.region
  az_a             = var.az_a
  az_b             = var.az_b
  az_c             = var.az_c
  az_d             = var.az_d
  account_id       = var.account_id
  tms_cert_arn     = aws_acm_certificate.tms_cert.arn
  tms_route53_zone = data.aws_route53_zone.tms.zone_id
  tms_cert         = aws_acm_certificate_validation.tms_cert.certificate_arn
}

module "fe" {
  source        = "./fe"
  project       = var.project
  instance_type = var.instance_type
  instance_ami  = var.instance_ami
  env           = var.env
  region        = var.region
  az_a          = var.az_a
  az_b          = var.az_b
  az_c          = var.az_c
  az_d          = var.az_d
  account_id    = var.account_id
  acm_cert_arn  = aws_acm_certificate.tms_cert_wildcard.arn
}
