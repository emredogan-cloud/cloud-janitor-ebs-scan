# Cloud Janitor – Orphan EBS Scanner (AWS Lambda + EventBridge Scheduler + Terraform)

Scans one or more AWS regions for **orphaned EBS volumes** (status = `available`), estimates monthly storage cost, and sends a report to Discord via webhook.

## Architecture
- AWS Lambda (Python)
- EventBridge Scheduler (daily trigger)
- IAM (least privilege)
- Terraform (IaC)
- CloudWatch Logs

## Prerequisites
- Terraform >= 1.5
- AWS CLI configured (credentials with permissions to create IAM/Lambda/Scheduler)
- Discord webhook URL

## Configuration (DO NOT COMMIT SECRETS)
Create `terraform/terraform.tfvars` locally:

```hcl
lambda_vars = {
  DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/REPLACE_ME"
  REGIONS             = "us-east-1,eu-central-1"
}
