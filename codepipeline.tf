resource "aws_codeconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}
