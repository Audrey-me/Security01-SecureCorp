# SecureCorp
A Secure multi-account AWS Architecture with Control tower and shared VPCs

# Project Overview
You're working at a growing company called SecureCorp. They build web apps for healthcare clients, so they handle sensitive data — emails, medical reports, and personal info.
SecureCorp is moving everything to the cloud (AWS).

But the CTO says:
“We want security to be built-in, not added later. We must separate our environments, monitor everything, and stay compliant (HIPAA, etc.). Security should scale as we grow.”
So now YOU are helping to design a secure cloud environment from day one.

# Technologies Used:
- AWS Services: Control Tower, IAM, Organizations, S3, VPC, EC2, Postgres on EC2, DynamoDB, CloudWatch, CloudTrail, GuardDuty, Security Hub, KMS, Route53, RAM, ECR, Lambda, SNS

- Networking: Shared VPCs, Subnet isolation, NAT Gateway

- CI/CD: GitHub Actions or CodePipeline

- Security Concepts: IAM Policies, SCPs, encryption, centralized logging, threat detection

#  Architecture Overview:
You’ll build an AWS multi-account environment structured like this:

🔐 1. Master Account (Organization Root)
AWS Organizations

Control Tower (for governance)

SCPs to restrict capabilities of sub-accounts

Guardrails (mandatory and elective)

🛡️ 2. Security Account
Centralized logging (CloudTrail, VPC Flow Logs, Config)

GuardDuty and Security Hub

SNS Notifications for alerts

Role for security team with read-only access to other accounts

🧪 3. Dev Account
Developers build/test apps here

Shared VPC accessed via RAM

IAM roles scoped to Dev

Hosts FastAPI app running on EC2 (backend) + Postgres on same EC2 instance

🚀 4. Prod Account
Only CI/CD pipelines can deploy

Same app as Dev, deployed via GitHub Actions

Read-only IAM roles for security audits

VPC shared from Network Account

S3 encrypted with KMS

🌐 5. Networking Account
Shared VPCs via RAM

Private and Public Subnets

Internet Gateway, NAT Gateway, Route Tables

VPC Peering (if needed between legacy and cloud)



