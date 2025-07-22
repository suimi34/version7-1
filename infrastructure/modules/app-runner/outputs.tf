output "app_runner_service_url" {
  description = "App Runner service URL"
  value       = "https://${aws_apprunner_service.main.service_url}"
}

output "app_runner_service_id" {
  description = "App Runner service ID"
  value       = aws_apprunner_service.main.service_id
}

output "app_runner_service_arn" {
  description = "App Runner service ARN"
  value       = aws_apprunner_service.main.arn
}

output "ssm_parameter_arns" {
  description = "SSM Parameter ARNs"
  value = {
    db_host         = aws_ssm_parameter.db_host.arn
    db_name         = aws_ssm_parameter.db_name.arn
    db_user         = aws_ssm_parameter.db_user.arn
    db_pass         = aws_ssm_parameter.db_pass.arn
    secret_key_base = aws_ssm_parameter.secret_key_base.arn
  }
}