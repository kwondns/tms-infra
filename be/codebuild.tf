resource "aws_codebuild_project" "tms_build" {
  name          = "${var.project}-build"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 15

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
    name     = "${var.project}-be-build"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "GITHUB"
    location        = var.github_be_repo_url
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }

  tags = {
    Name = "${var.project}-be-codebuild"
  }
}
