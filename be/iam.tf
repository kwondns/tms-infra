resource "aws_iam_role" "tms_ec2_role" {
  name               = "tms_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}


data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "tms_s3_read_policy"
  description = "Allow EC2 to read objects from S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.project}-server-artifacts",
          "arn:aws:s3:::${var.project}-server-artifacts/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.tms_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.tms_ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_secret" {
  role = aws_iam_role.tms_ec2_role.name
  name = "tms_ec2_instance_profile"
}

resource "aws_iam_policy" "rds_proxy_secrets_access" {
  name        = "RDSProxySecretsAccess"
  description = "Allows RDS Proxy to access Secrets Manager and KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.tms_secret.arn,
          "${aws_secretsmanager_secret.tms_secret.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = "arn:aws:kms:${var.region}:${var.account_id}:key/${aws_secretsmanager_secret.tms_secret.id}"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tms_rds_proxy_policy" {
  role       = aws_iam_role.tms_rds_proxy_role.name
  policy_arn = aws_iam_policy.rds_proxy_secrets_access.arn
}

resource "aws_iam_role" "tms_rds_proxy_role" {
  name = "rds-proxy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "rds.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project}-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.artifact_bucket.arn,
          "${aws_s3_bucket.artifact_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild", "codebuild:BatchGetBuilds"
        ],
        Resource = [aws_codebuild_project.tms_build.arn]
      }
    ]
  })
}

# CodeDeploy
resource "aws_iam_role" "codedeploy_ec2" {
  name               = "codedeploy-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}


resource "aws_iam_instance_profile" "codedeploy_profile" {
  name = "codedeploy-ec2-profile"
  role = aws_iam_role.codedeploy_ec2.name
}

resource "aws_iam_role" "tms_codedeploy_service" {
  name = "code_deploy_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tms_codedeploy_service" {
  role       = aws_iam_role.tms_codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# # RDS Proxy 대상 그룹 조회 권한 추가
# resource "aws_iam_policy" "rds_proxy_target_group_policy" {
#   name        = "RDSProxyTargetGroupAccess"
#   description = "Allow DescribeDBProxyTargets action for specific target group"
#
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         "Action" : [
#           "rds:DescribeDBProxyTargets",
#           "rds:DescribeDBProxies",
#           "rds:DescribeDBProxyTargetGroups"
#         ],
#         Resource = ["*"]
#       }
#     ]
#   })
# }
#
#
# resource "aws_iam_role_policy_attachment" "rds_proxy_read_attach" {
#   role       = aws_iam_role.tms_ec2_role.name
#   policy_arn = aws_iam_policy.rds_proxy_target_group_policy.arn
# }

# resource "aws_iam_role" "archive_bucket_role" {
#   name = "tms-archive-role-${random_id.bucket_suffix.hex}"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com" # 사용할 서비스 변경 가능
#         }
#       }
#     ]
#   })
#
#   tags = {
#     Environment = "production"
#     Service     = "compression-service"
#   }
# }

# data "aws_iam_policy_document" "archive_bucket_policy" {
#   statement {
#     sid    = "AllowS3BucketAccess"
#     effect = "Allow"
#
#     actions = [
#       "s3:ListBucket",
#       "s3:GetBucketLocation"
#     ]
#
#     resources = [
#       aws_s3_bucket.tms_archive_temp.arn
#     ]
#   }
#
#   statement {
#     sid    = "AllowObjectOperations"
#     effect = "Allow"
#
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:DeleteObject",
#       "s3:PutObjectAcl", # 추가 필요
#       "s3:AbortMultipartUpload"
#     ]
#
#     principals {
#       type = "AWS"
#       identifiers = [aws_iam_role.archive_bucket_role.arn]
#     }
#
#     resources = [
#       "${aws_s3_bucket.tms_archive_temp.arn}/*"
#     ]
#   }
#
#   statement {
#     sid    = "AllowLifecycleManagement"
#     effect = "Allow"
#
#     actions = [
#       "s3:PutLifecycleConfiguration",
#       "s3:GetLifecycleConfiguration"
#     ]
#
#     resources = [
#       aws_s3_bucket.tms_archive_temp.arn
#     ]
#   }
# }
#
# resource "aws_iam_policy" "archive_bucket_policy" {
#   name        = "tms-archive-policy-${random_id.bucket_suffix.hex}"
#   description = "Policy for accessing archive bucket"
#   policy      = data.aws_iam_policy_document.archive_bucket_policy.json
# }
#
# # 역할에 정책 연결
# resource "aws_iam_role_policy_attachment" "archive_bucket_attach" {
#   role       = aws_iam_role.archive_bucket_role.name
#   policy_arn = aws_iam_policy.archive_bucket_policy.arn
# }


resource "aws_iam_role" "lambda_role" {
  name = "timeline-chatbot-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "timeline-chatbot-lambda-role-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.timeline_time_weighted_vector_store_bucket.arn}/*",
          aws_s3_bucket.timeline_time_weighted_vector_store_bucket.arn
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_efs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}
