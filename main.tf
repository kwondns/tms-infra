provider "aws" {
  region = "ap-northeast-2" # Seoul
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_route53_zone" "tms" {
  name = "kwondns.com."      # 도메인 이름 끝에 점(.) 포함 (권장)
  private_zone = false               # 퍼블릭 존일 경우 false
}

module "be" {
  source                = "./be"
  project               = var.project
  instance_type         = var.instance_type
  instance_ami          = var.instance_ami
  env                   = var.env
  region                = var.region
  az_a                  = var.az_a
  az_b                  = var.az_b
  az_c                  = var.az_c
  az_d                  = var.az_d
  account_id            = var.account_id
  tms_cert_arn          = aws_acm_certificate.tms_cert.arn
  tms_route53_zone      = data.aws_route53_zone.tms.zone_id
  tms_cert              = aws_acm_certificate_validation.tms_cert.certificate_arn
  tms_cert_wildcard_arn = aws_acm_certificate.tms_cert_wildcard.arn
  github_connection     = aws_codeconnections_connection.github.arn
}

module "fe" {
  source             = "./modules/frontend-deployment"
  project            = var.project
  acm_cert_arn       = aws_acm_certificate.tms_cert_wildcard.arn
  github_connection  = aws_codeconnections_connection.github.arn
  bucket_name        = "tms-web-site"
  cloudfront_alias   = "tms.kwondns.com"
  github_fe_branch   = "dev"
  github_fe_repo     = "kwondns/tms-web"
  github_fe_repo_url = "https://github.com/kwondns/tms-web"
  environment_variables = {
    vite_api_server_url = {
      name  = "VITE_API_SERVER_URL"
      value = "https://api.kwondns.com"
    }

    vite_ws_server_url = {
      name  = "VITE_WS_SERVER_URL"
      value = "wss://api.kwondns.com"
    }
  }
  zone_id = data.aws_route53_zone.tms.zone_id
}

# module "port" {
#   source             = "./modules/frontend-deployment"
#   project            = "portfolio"
#   acm_cert_arn       = aws_acm_certificate.tms_cert_wildcard.arn
#   bucket_name        = "tms-port-web-site"
#   github_connection  = aws_codeconnections_connection.github.arn
#   cloudfront_alias   = "port.kwondns.com"
#   github_fe_branch   = "main"
#   github_fe_repo     = "kwondns/portfolio"
#   github_fe_repo_url = "https://github.com/kwondns/portfolio"
#   environment_variables = {
#     vite_api_server_url = {
#       name  = "VITE_API_SERVER_URL"
#       value = "https://api.kwondns.com"
#     }
#
#     vite_image_url = {
#       name  = "VITE_IMAGE_URL"
#       value = "https://tms-portfolio.s3.ap-northeast-2.amazonaws.com"
#     }
#   }
#   zone_id = data.aws_route53_zone.tms.zone_id
# }

module "drive" {
  source             = "./modules/frontend-deployment"
  project            = "drive"
  acm_cert_arn       = aws_acm_certificate.tms_cert_wildcard.arn
  bucket_name        = "tms-drive-web-site"
  github_connection  = aws_codeconnections_connection.github.arn
  github_fe_branch   = "master"
  github_fe_repo     = "kwondns/drive"
  github_fe_repo_url = "https://github.com/kwondns/drive"
  cloudfront_alias   = "drive.kwondns.com"
  environment_variables = {
    vite_api_url = {
      name  = "VITE_API_URL"
      value = "https://api.kwondns.com/drive"
    }

    vite_profile_img_url = {
      name  = "VITE_PROFILE_IMG_URL"
      value = "https://tms-drive-user-profile.s3.ap-northeast-2.amazonaws.com"
    }

    vite_img_url = {
      name  = "VITE_IMG_URL"
      value = "https://tms-drive-user.s3.ap-northeast-2.amazonaws.com"
    }
  }
  zone_id = data.aws_route53_zone.tms.zone_id
}

module "house" {
  source             = "./modules/frontend-deployment"
  project            = "house-connect"
  acm_cert_arn       = aws_acm_certificate.tms_cert_wildcard.arn
  bucket_name        = "tms-house-web-site"
  github_connection  = aws_codeconnections_connection.github.arn
  github_fe_branch   = "main"
  github_fe_repo     = "kwondns/house-connect"
  github_fe_repo_url = "https://github.com/kwondns/house-connect"
  cloudfront_alias   = "house.kwondns.com"
  environment_variables = {
    vite_supabase_url = {
      name  = "VITE_SUPABASE_URL"
      value = "https://tbuvhnpxnsntgvfachoy.supabase.co"
    }

    vite_supabase_key = {
      name  = "VITE_SUPABASE_KEY"
      value = var.house_vite_supabase_key
    }

    vite_supabase_storage_url = {
      name  = "VITE_SUPABASE_STORAGE_URL"
      value = "https://tbuvhnpxnsntgvfachoy.supabase.co/storage/v1/object/public/images"
    }

    vite_kakao_redirect_url = {
      name  = "VITE_KAKAO_REDIRECT_URL"
      value = "https://house.kwondns.com/sign"
    }
  }
  zone_id = data.aws_route53_zone.tms.zone_id
}

module "timeline" {
  source             = "./modules/frontend-deployment"
  project            = "timeline"
  acm_cert_arn       = aws_acm_certificate.tms_cert_wildcard.arn
  bucket_name        = "tms-timeline-web-site"
  github_connection  = aws_codeconnections_connection.github.arn
  github_fe_branch   = "master"
  github_fe_repo     = "kwondns/timeline"
  github_fe_repo_url = "https://github.com/kwondns/timeline"
  cloudfront_alias   = "timeline.kwondns.com"
  environment_variables = {
    vite_api_server_url = {
      name  = "VITE_API_SERVER_URL"
      value = "https://api.kwondns.com"
    }

    vite_ws_server_url = {
      name  = "VITE_WS_SERVER_URL"
      value = "wss://api.kwondns.com"
    }

    vite_image_url = {
      name  = "VITE_IMAGE_URL"
      value = "https://tms-timeline.s3.ap-northeast-2.amazonaws.com"
    }
    vite_chat_url = {
      name = "VITE_CHAT_URL"
      value = module.be.chatbot_lambda_url
    }
  }
  zone_id = data.aws_route53_zone.tms.zone_id
}
