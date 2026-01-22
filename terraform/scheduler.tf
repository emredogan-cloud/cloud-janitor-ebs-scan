
resource "aws_iam_role" "scheduler_role" {
  name = "cloud-janitor-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "scheduler_policy" {
  name        = "cloud-janitor-scheduler-invoke"
  description = "Allow EventBridge Scheduler to invoke the Cloud Janitor Lambda function."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = aws_lambda_function.lambda_func.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_attach" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}

resource "aws_scheduler_schedule" "daily_scan" {
  name        = "cloud-janitor-daily-scan"
  description = "Daily orphan EBS scan with Discord reporting."

  schedule_expression          = "cron(0 9 * * ? *)"
  schedule_expression_timezone = "Europe/Istanbul"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.lambda_func.arn
    role_arn = aws_iam_role.scheduler_role.arn
    input    = "{}"
  }

  depends_on = [aws_iam_role_policy_attachment.scheduler_attach]

resource "aws_lambda_permission" "allow_scheduler" {
  statement_id  = "AllowEventBridgeSchedulerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.daily_scan.arn
}
