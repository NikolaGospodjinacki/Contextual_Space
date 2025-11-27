# GitHub Actions OIDC Provider and IAM Role
# This allows GitHub Actions to authenticate with AWS without storing access keys

# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]

  tags = {
    Name = "github-actions-oidc"
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "${var.app_name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Replace with your GitHub repo - allows any branch
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-github-actions"
  }
}

# Policy for GitHub Actions - ECR, S3, CloudFront, App Runner
resource "aws_iam_policy" "github_actions" {
  name = "${var.app_name}-github-actions-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR permissions for backend deployment
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.backend.arn
      },
      # App Runner permissions
      {
        Effect = "Allow"
        Action = [
          "apprunner:ListServices",
          "apprunner:DescribeService",
          "apprunner:StartDeployment"
        ]
        Resource = "*"
      },
      # S3 permissions for frontend deployment
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.frontend.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      },
      # CloudFront permissions
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = aws_cloudfront_distribution.frontend.arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# Output the role ARN for GitHub secrets
output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions (add this to GitHub secrets as AWS_ROLE_ARN)"
  value       = aws_iam_role.github_actions.arn
}
