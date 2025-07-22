variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "container_image" {
  description = "Rails container image URI"
  type        = string
}

variable "nginx_image" {
  description = "Nginx container image URI"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for Rails container"
  type        = map(string)
  default     = {}
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