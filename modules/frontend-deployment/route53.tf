resource "aws_route53_record" "route53" {
  zone_id = var.zone_id
  name    = var.cloudfront_alias
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
