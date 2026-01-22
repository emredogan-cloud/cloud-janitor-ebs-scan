
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../src/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}


resource "aws_lambda_function" "lambda_func" {
  function_name = "cloud-janitor-ebs-scan"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 300
  memory_size = 512

  environment {
    variables = {
      DISCORD_WEBHOOK_URL = var.lambda_vars.DISCORD_WEBHOOK_URL
      REGIONS             = var.lambda_vars.REGIONS
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_logs,
    aws_iam_role_policy_attachment.attach_ec2
  ]

  timeouts {
    create = "5m"
  }
}
