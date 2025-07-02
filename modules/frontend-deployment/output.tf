output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.website_distribution.domain_name
}

output "cloudfront_zone_id" {
  value = aws_cloudfront_distribution.website_distribution.hosted_zone_id
}
