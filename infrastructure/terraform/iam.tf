# IAM Role for App Runner to access ECR and DynamoDB

# App Runner ECR Access Role
resource "aws_iam_role" "apprunner_ecr_access" {
  name = "${var.app_name}-apprunner-ecr-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# App Runner Instance Role (for DynamoDB access)
resource "aws_iam_role" "apprunner_instance" {
  name = "${var.app_name}-apprunner-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# DynamoDB access policy for App Runner
resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.app_name}-dynamodb-access"
  description = "Allow App Runner to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.textboxes.arn,
          "${aws_dynamodb_table.textboxes.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_dynamodb" {
  role       = aws_iam_role.apprunner_instance.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

output "apprunner_ecr_role_arn" {
  description = "App Runner ECR access role ARN"
  value       = aws_iam_role.apprunner_ecr_access.arn
}

output "apprunner_instance_role_arn" {
  description = "App Runner instance role ARN"
  value       = aws_iam_role.apprunner_instance.arn
}
