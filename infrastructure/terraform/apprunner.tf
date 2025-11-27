# App Runner Service for Backend

# Auto-scaling configuration with minimum 1 instance to avoid cold starts
resource "aws_apprunner_auto_scaling_configuration_version" "backend" {
  auto_scaling_configuration_name = "${var.app_name}-backend-${var.environment}"

  min_size = 1  # Always keep 1 instance warm - avoids cold starts
  max_size = 5  # Scale up to 5 instances under load

  tags = {
    Name = "${var.app_name}-backend-autoscaling"
  }
}

resource "aws_apprunner_service" "backend" {
  service_name = "${var.app_name}-backend-${var.environment}"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access.arn
    }

    image_repository {
      image_configuration {
        port = tostring(var.backend_port)
        runtime_environment_variables = {
          NODE_ENV            = var.environment == "prod" ? "production" : "development"
          PORT                = tostring(var.backend_port)
          DYNAMODB_TABLE_NAME = aws_dynamodb_table.textboxes.name
          AWS_REGION          = var.aws_region
          FRONTEND_URL        = "https://${aws_cloudfront_distribution.frontend.domain_name}"
          USE_DYNAMODB        = "true"
        }
      }
      image_identifier      = "${aws_ecr_repository.backend.repository_url}:latest"
      image_repository_type = "ECR"
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu               = var.app_runner_cpu
    memory            = var.app_runner_memory
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  # Keep 1 instance always warm to avoid cold starts
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.backend.arn

  health_check_configuration {
    healthy_threshold   = 1
    interval            = 10
    path                = "/health"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 5
  }

  tags = {
    Name = "${var.app_name}-backend"
  }

  # Don't create until ECR has an image
  depends_on = [aws_ecr_repository.backend]
}

output "apprunner_service_url" {
  description = "App Runner service URL"
  value       = aws_apprunner_service.backend.service_url
}

output "apprunner_service_arn" {
  description = "App Runner service ARN"
  value       = aws_apprunner_service.backend.arn
}
