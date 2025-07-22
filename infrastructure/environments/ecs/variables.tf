# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

# Project Configuration
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "tf-version7-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "production"
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.4.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
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

variable "nginx_image" {
  description = "Docker image for Nginx"
  type        = string
}

variable "health_check_path" {
  description = "Health check path for load balancer"
  type        = string
  default     = "/health"
}

# ECS Task Configuration
variable "task_cpu" {
  description = "CPU units for ECS task"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Memory for ECS task"
  type        = number
  default     = 1024
}

variable "rails_cpu" {
  description = "CPU units for Rails container"
  type        = number
  default     = 512
}

variable "rails_memory" {
  description = "Memory for Rails container"
  type        = number
  default     = 512
}

variable "nginx_cpu" {
  description = "CPU units for Nginx container"
  type        = number
  default     = 256
}

variable "nginx_memory" {
  description = "Memory for Nginx container"
  type        = number
  default     = 256
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
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
