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

# Container Configuration
variable "repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "version7-1/rails"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "health_check_path" {
  description = "Health check path for App Runner"
  type        = string
  default     = "/up"
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

# App Runner Configuration
variable "app_runner_cpu" {
  description = "CPU units for the App Runner service (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "app_runner_memory" {
  description = "Memory for the App Runner service (512, 1024, 2048, 3072, 4096, 6144, 8192, 10240, 12288)"
  type        = string
  default     = "512"
}

variable "app_runner_port" {
  description = "Port that the application listens on"
  type        = string
  default     = "3000"
}

# Auto Scaling Configuration
variable "min_size" {
  description = "Minimum number of App Runner instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of App Runner instances"
  type        = number
  default     = 1
}

# Additional Environment Variables
variable "additional_environment_variables" {
  description = "Additional environment variables for the App Runner service"
  type        = map(string)
  default     = {}
}
