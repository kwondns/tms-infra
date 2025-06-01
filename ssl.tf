resource "aws_acm_certificate" "tms_cert" {
  domain_name       = "api.kwondns.com"
  validation_method = "DNS"
  tags = {
    Name = "tms-api-cert"
  }
}

resource "aws_acm_certificate" "tms_cert_wildcard" {
  provider          = aws.virginia
  domain_name       = "*.kwondns.com"
  validation_method = "DNS"
}


resource "aws_route53_record" "tms_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tms_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = data.aws_route53_zone.tms.zone_id
  name            = each.value.name
  type            = each.value.type
  records = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}
resource "aws_route53_record" "tms_cert_wildcard_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tms_cert_wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = data.aws_route53_zone.tms.zone_id
  name            = each.value.name
  type            = each.value.type
  records = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}
resource "aws_acm_certificate_validation" "tms_cert_wildcard" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.tms_cert_wildcard.arn
  validation_record_fqdns = [for record in aws_route53_record.tms_cert_wildcard_validation : record.fqdn]
}

resource "aws_acm_certificate_validation" "tms_cert" {
  certificate_arn         = aws_acm_certificate.tms_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.tms_cert_validation : record.fqdn]
}
resource "aws_route53_record" "tms_root" {
  zone_id = data.aws_route53_zone.tms.zone_id
  name    = "dashboard.kwondns.com"
  type    = "A"
  alias {
    name                   = module.fe.cloudfront_domain_name
    zone_id                = module.fe.cloudfront_zone_id
    evaluate_target_health = false
  }
}
