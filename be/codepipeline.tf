resource "aws_codepipeline" "pipeline" {
  name     = "${var.project}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection
        FullRepositoryId = var.github_be_repo
        BranchName       = var.github_be_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version  = "1"

      configuration = {
        ProjectName = aws_codebuild_project.tms_build.name
        # EnvironmentVariables = jsonencode([
        #   {
        #     name  = "DB_HOST"
        #     value = aws_db_proxy.tms_db_proxy.endpoint
        #     type  = "PLAINTEXT"
        #   },
        #   {
        #     name  = "DB_PORT"
        #     value = var.db_port
        #     type  = "PLAINTEXT"
        #   },
        # ])
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "CodeDeploy"
      input_artifacts = ["build_output"]
      version  = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.tms_backend.name
        DeploymentGroupName = aws_codedeploy_deployment_group.tms_backend.deployment_group_name
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.artifact_bucket.arn,
          "${aws_s3_bucket.artifact_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = [aws_iam_role.codebuild_role.arn, aws_iam_role.codedeploy_ec2.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = [aws_iam_role.codebuild_role.arn, aws_iam_role.codedeploy_ec2.arn]
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [aws_iam_role.codebuild_role.arn, aws_iam_role.codedeploy_ec2.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection", "codestar-connections:UseConnection"
        ]
        Resource = var.github_connection
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild", "codebuild:BatchGetBuilds"
        ],
        Resource = [aws_codebuild_project.tms_build.arn]
      },
      {
        Effect = "Allow"
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        # Resource = [
        #   aws_codedeploy_deployment_group.tms_backend.arn,
        #   aws_codedeploy_app.tms_backend.arn,
        #   "arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime"
        # ]
        Resource = "*"
      }
    ]
  })
}
