# DynamoDB table for storing text boxes

resource "aws_dynamodb_table" "textboxes" {
  name         = "${var.app_name}-textboxes-${var.environment}"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Enable point-in-time recovery for data protection
  point_in_time_recovery {
    enabled = true
  }

  # TTL for automatic cleanup (optional, not enabled by default)
  # ttl {
  #   attribute_name = "expiresAt"
  #   enabled        = true
  # }

  tags = {
    Name = "${var.app_name}-textboxes"
  }
}

# Output the table name and ARN
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.textboxes.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.textboxes.arn
}
