# Variables for Contextual Space Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "contextual-space"
}

# DynamoDB
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# App Runner
variable "app_runner_cpu" {
  description = "CPU units for App Runner (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "app_runner_memory" {
  description = "Memory in MB for App Runner (512, 1024, 2048, 3072, 4096, ...)"
  type        = string
  default     = "512"
}

variable "backend_port" {
  description = "Port the backend container listens on"
  type        = number
  default     = 3001
}

# Domain (optional)
variable "domain_name" {
  description = "Custom domain name (optional)"
  type        = string
  default     = ""
}

# GitHub Actions
variable "github_repo" {
  description = "GitHub repository in format owner/repo for OIDC authentication"
  type        = string
  default     = "NikolaGospodjinacki/Contextual_Space"
}
