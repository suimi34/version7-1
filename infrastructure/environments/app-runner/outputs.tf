output "app_runner_service_url" {
  description = "App Runner service URL"
  value       = module.app_runner.app_runner_service_url
}

output "app_runner_service_id" {
  description = "App Runner service ID"
  value       = module.app_runner.app_runner_service_id
}

output "app_runner_service_arn" {
  description = "App Runner service ARN"
  value       = module.app_runner.app_runner_service_arn
}

output "ssm_parameter_arns" {
  description = "SSM Parameter ARNs"
  value       = module.app_runner.ssm_parameter_arns
}
