resource "aws_codebuild_project" "tms_fe_build" {
  name          = "${var.project}-fe-build"
  service_role  = aws_iam_role.codebuild_fe_role.arn
  build_timeout = 15

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "VITE_API_SERVER_URL"
      value = "https://api.kwondns.com"
    }

    environment_variable {
      name  = "VITE_IMAGE_URL"
      value = "https://tms-portfolio.s3.ap-northeast-2.amazonaws.com"
    }

  }

  source {
    type            = "GITHUB"
    location        = var.github_fe_repo_url
    git_clone_depth = 1
    buildspec       = <<EOF
---
version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: 20
    commands:
      - yarn install
  build:
    commands:
      - echo Build started on \`date\`
      - yarn run build
  post_build:
    commands:
      - aws s3 cp --recursive ./dist s3://${aws_s3_bucket.website_bucket.bucket}/
      - >
        aws s3 cp
        --cache-control="max-age=0, no-cache, no-store, must-revalidate"
        ./dist/index.html s3://${aws_s3_bucket.website_bucket.bucket}/
artifacts:
  files:
    - '**/*'
  base-directory: dist
EOF
  }

  artifacts {
    type     = "NO_ARTIFACTS"
  }

  tags = {
    Name = "${var.project}-fe-codebuild"
  }
}
