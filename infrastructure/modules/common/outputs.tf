output "common_tags" {
  description = "Common tags for all resources"
  value = {
    Name        = var.project_name
    Environment = var.environment
    Project     = var.project_name
  }
}

output "rails_environment_variables" {
  description = "Common Rails environment variables"
  value = {
    RAILS_ENV       = var.rails_env
    DB_HOST         = var.db_host
    DB_PORT         = tostring(var.db_port)
    DB_NAME         = var.db_name
    DB_USER         = var.db_user
    DB_PASS         = var.db_pass
    SECRET_KEY_BASE = var.secret_key_base
  }
  sensitive = true
}

output "container_image" {
  description = "Full container image URI"
  value       = "${var.repository_url}:${var.image_tag}"
}