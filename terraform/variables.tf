variable "aws_region" {
  description = "AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

# Lambda environment variables are modeled as a single object to keep configuration tidy.
# Provide values via terraform.tfvars (do not commit secrets).
variable "lambda_vars" {
  description = "Environment variables injected into the Lambda function."
  type = object({
    DISCORD_WEBHOOK_URL = string
    REGIONS             = string
  })
  sensitive = true
}
