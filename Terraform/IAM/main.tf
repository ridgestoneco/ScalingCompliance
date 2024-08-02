provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "team_audit" {
  name = "TeamAuditRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "team_audit_policy" {
  name        = "TeamAuditPolicy"
  description = "Read-only access to EC2, VPC, and IAM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "vpc:Describe*",
          "iam:Get*",
          "iam:List*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_team_audit_policy" {
  role       = aws_iam_role.team_audit.name
  policy_arn = aws_iam_policy.team_audit_policy.arn
}

output "role_name" {
  value = aws_iam_role.team_audit.name
}

output "policy_arn" {
  value = aws_iam_policy.team_audit_policy.arn
}
