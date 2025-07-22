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

# Networking module for VPC, subnets, etc.
module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  common_tags          = module.common.common_tags
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
}

# ECS module for Fargate deployment
module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  aws_region            = var.aws_region
  common_tags           = module.common.common_tags
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  container_image       = module.common.container_image
  nginx_image           = var.nginx_image
  environment_variables = module.common.rails_environment_variables
  health_check_path     = var.health_check_path

  # ECS-specific configuration
  task_cpu      = var.task_cpu
  task_memory   = var.task_memory
  rails_cpu     = var.rails_cpu
  rails_memory  = var.rails_memory
  nginx_cpu     = var.nginx_cpu
  nginx_memory  = var.nginx_memory
  desired_count = var.desired_count
}
