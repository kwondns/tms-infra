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

resource "aws_codebuild_project" "timeline_chatbot_build" {
  name          = "${var.project}-timeline-chatbot-build"
  description   = "Build project for timeline chatbot Docker image"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode            = true  # Docker 빌드를 위해 필요

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.timeline_chatbot_repo.name
    }

    environment_variable {
      name  = "LAMBDA_FUNCTION_NAME"
      value = aws_lambda_function.timeline_chatbot.function_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = "production"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = {
    Name = "${var.project}-timeline-chatbot-build"
  }
}

data "aws_caller_identity" "current" {}
