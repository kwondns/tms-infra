resource "aws_codedeploy_app" "tms_backend" {
  name             = "${var.project}-be"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "tms_backend" {
  app_name              = aws_codedeploy_app.tms_backend.name
  deployment_group_name = "${var.project}_code_deploy_group"
  service_role_arn      = aws_iam_role.tms_codedeploy_service.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "deploy"
      type  = "KEY_AND_VALUE"
      value = "CodeDeploy"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_type = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }
}
