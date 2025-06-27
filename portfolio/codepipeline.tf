resource "aws_codepipeline" "fe-pipeline" {
  name     = "${var.project}-fe-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.website_bucket.bucket
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
        FullRepositoryId = var.github_fe_repo
        BranchName       = var.github_fe_branch
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
        ProjectName = aws_codebuild_project.tms_fe_build.name
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
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project}-fe-codepipeline-role"

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
  name = "${var.project}-fe-codepipeline-policy"
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
          aws_s3_bucket.website_bucket.arn,
          "${aws_s3_bucket.website_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = [aws_iam_role.codebuild_fe_role.arn]
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
        Resource = [aws_iam_role.codebuild_fe_role.arn]
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [aws_iam_role.codebuild_fe_role.arn]
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
        Resource = [aws_codebuild_project.tms_fe_build.arn]
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
        Resource = "*"
      }
    ]
  })
}
