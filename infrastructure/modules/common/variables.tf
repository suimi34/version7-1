# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-1"
}

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "version7-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "production"
}

# Database Configuration
variable "db_host" {
  description = "Database host for Rails application"
  type        = string
}

variable "db_port" {
  description = "Database port for Rails application"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Database name for Rails application"
  type        = string
  default     = "ze580_version7_1"
}

variable "db_user" {
  description = "Database user for Rails application"
  type        = string
  default     = "ze580_version7_1"
}

variable "db_pass" {
  description = "Database password for Rails application"
  type        = string
  sensitive   = true
}

# Rails Configuration
variable "secret_key_base" {
  description = "Secret key base for Rails application"
  type        = string
  sensitive   = true
}

variable "rails_env" {
  description = "Environment for Rails application"
  type        = string
  default     = "production"
}

# Container Configuration
variable "repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}