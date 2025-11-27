# Outputs for all infrastructure

output "backend_url" {
  description = "Backend API URL"
  value       = "https://${aws_apprunner_service.backend.service_url}"
}

output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}
