# Data Sources
# Use the SSO provider for Identity Center
######################################################
data "aws_ssoadmin_instances" "main" {}

######################################################
# SecureCorp Permission Sets
######################################################

# For Infrastruture OU
resource "aws_ssoadmin_permission_set" "sc_infra_network" {
  name = "sc-infra-network-ps"
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  description = "permission set for network Admins (VPC, TGW, routes)"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "sc_infra_network" {
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "NetworkAdmin"
        Effect   = "Allow"
        Action   = [
          "ec2:Describe*",
          "ec2:CreateVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DeleteVpc",
          "ec2:CreateTransitGateway",
          "ec2:DeleteTransitGateway",
          "ec2:ModifyTransitGateway*",
          "ec2:CreateRoute*",
          "ec2:DeleteRoute*"
        ]
        Resource = "*"
      }
    ]
  })
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_infra_network.arn
}

# For Workflow OU
    # for dev
resource "aws_ssoadmin_permission_set" "sc_workflow_dev" {
    name = "sc-workflow-dev-ps"
    instance_arn = data.aws_ssoadmin_instances.main.arns[0]
    description  = "Developers in dev account (PowerUser minus IAM/KMS)"
}
# resource "aws_ssoadmin_permission_set_inline_policy" "sc_workflow_dev" {
#   inline_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid      = "Dev Environment"
#         Effect   = "Deny"
#         Action   = [
#           "iam:*",
#           "kms:*",
#         ]
#         Resource = "*"
#       }
#     ]
#   })
#   instance_arn = data.aws_ssoadmin_instances.main.arns[0]
#   permission_set_arn = aws_ssoadmin_permission_set.sc_workflow_dev.arn
# }

resource "aws_ssoadmin_managed_policy_attachment" "sc_workflow_dev_poweruser" {
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_workflow_dev.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
    # for prod
resource "aws_ssoadmin_permission_set" "sc_workflow_prod" {
    name = "sc-workflow-prod-ps"
    instance_arn = data.aws_ssoadmin_instances.main.arns[0]
    description  = "Developers in Prod account (PowerUser minus IAM/KMS)"
}
resource "aws_ssoadmin_managed_policy_attachment" "sc_workflow_prod_cf" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_workflow_prod.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "sc_workflow_prod_cd" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_workflow_prod.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "sc_workflow_prod_cp" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_workflow_prod.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "sc_workflow_prod_cw" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_workflow_prod.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
resource "aws_ssoadmin_managed_policy_attachment" "sc_workflow_prod_readonly" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_workflow_prod.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


# For Security OU
    # Auditors
resource "aws_ssoadmin_permission_set" "sc_security_audit" {
  name         = "sc-security-audit-ps"
  description  = "Security team read-only across accounts"
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  session_duration = "PT8H"
}
resource "aws_ssoadmin_managed_policy_attachment" "sc_security_audit" {
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_security_audit.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
resource "aws_ssoadmin_permission_set_inline_policy" "sc_security_audit" {  
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ExtraRead"
        Effect = "Allow"
        Action = [
          "kms:ListKeys",
          "kms:DescribeKey",
          "cloudtrail:Get*",
          "cloudtrail:Describe*",
          "config:Describe*",
          "config:Get*",
          "guardduty:Get*",
          "guardduty:List*",
          "securityhub:Get*",
          "securityhub:List*"
        ]
        Resource = "*"
      }
    ]
  })
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.sc_security_audit.arn
}

    # Logs Writers (services writing to central log bucket)
resource "aws_ssoadmin_permission_set" "sc_security_log" {
  name         = "sc-security-log-ps"
  description  = "Services allowed to write logs to central account"
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
  session_duration = "PT1H"
}
resource "aws_ssoadmin_permission_set_inline_policy" "sc_security_log" {
    inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteS3Logs"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging"
        ]
        Resource = "arn:aws:s3:::securecorp-central-logs/*"
      },
      {
        Sid    = "WriteCWLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/securecorp/*"
      }
    ]
  })
   instance_arn = data.aws_ssoadmin_instances.main.arns[0]
   permission_set_arn = aws_ssoadmin_permission_set.sc_security_log.arn
}
