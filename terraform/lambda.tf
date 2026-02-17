resource "aws_lambda_function" "lambda_func" {
  function_name = "cloud-janitor-ebs-scan"

  package_type = "Image"

  image_uri = "${aws_ecr_repository.repo.repository_url}:latest"

  role        = aws_iam_role.lambda_role.arn
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
    aws_iam_role_policy_attachment.attach_ec2,
    null_resource.docker_build_push
  ]
}