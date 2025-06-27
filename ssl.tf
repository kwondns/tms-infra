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
  name    = "tms.kwondns.com"
  type    = "A"
  alias {
    name                   = module.fe.cloudfront_domain_name
    zone_id                = module.fe.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "portfolio" {
  zone_id = data.aws_route53_zone.tms.zone_id
  name    = "port.kwondns.com"
  type    = "A"
  alias {
    name                   = module.port.cloudfront_domain_name
    zone_id                = module.port.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "drive" {
  zone_id = data.aws_route53_zone.tms.zone_id
  name    = "drive.kwondns.com"
  type    = "A"
  alias {
    name                   = module.drive.cloudfront_domain_name
    zone_id                = module.drive.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "house" {
  zone_id = data.aws_route53_zone.tms.zone_id
  name    = "house.kwondns.com"
  type    = "A"
  alias {
    name                   = module.house.cloudfront_domain_name
    zone_id                = module.house.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "timeline" {
  zone_id = data.aws_route53_zone.tms.zone_id
  name    = "timeline.kwondns.com"
  type    = "A"
  alias {
    name                   = module.timeline.cloudfront_domain_name
    zone_id                = module.timeline.cloudfront_zone_id
    evaluate_target_health = false
  }
}
