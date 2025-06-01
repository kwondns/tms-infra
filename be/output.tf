output "ec2_public_ip" {
  value = aws_instance.tms_backend_a.public_ip
}

output "ec2_ssh_private_key" {
  value     = tls_private_key.tms_ec2_key.private_key_pem
  sensitive = true
}

output "ec2_lb_arn" {
  value = aws_lb_listener.tms_https.arn
}

# output "s3_archive_stream_bucket" {
#   value = aws_s3_bucket.tms_archive_temp.bucket
# }
