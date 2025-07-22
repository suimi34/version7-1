terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Common module for shared variables and outputs
module "common" {
  source = "../../modules/common"

  aws_region      = var.aws_region
  project_name    = var.project_name
  environment     = var.environment
  db_host         = var.db_host
  db_port         = var.db_port
  db_name         = var.db_name
  db_user         = var.db_user
  db_pass         = var.db_pass
  secret_key_base = var.secret_key_base
  rails_env       = var.rails_env
  repository_url  = var.repository_url
  image_tag       = var.image_tag
}

# App Runner module
module "app_runner" {
  source = "../../modules/app-runner"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  common_tags           = module.common.common_tags
  container_image       = module.common.container_image
  repository_name       = var.repository_name
  environment_variables = merge(module.common.rails_environment_variables, var.additional_environment_variables)
  health_check_path     = var.health_check_path

  # Database configuration passed through
  db_host         = var.db_host
  db_port         = var.db_port
  db_name         = var.db_name
  db_user         = var.db_user
  db_pass         = var.db_pass
  secret_key_base = var.secret_key_base

  # App Runner specific configuration
  app_runner_cpu    = var.app_runner_cpu
  app_runner_memory = var.app_runner_memory
  app_runner_port   = var.app_runner_port
  min_size          = var.min_size
  max_size          = var.max_size
}
