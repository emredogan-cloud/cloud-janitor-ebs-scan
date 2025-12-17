output "lambda_function_name" {
  description = "Deployed Lambda function name."
  value       = aws_lambda_function.lambda_func.function_name
}

output "schedule_name" {
  description = "EventBridge Scheduler schedule name."
  value       = aws_scheduler_schedule.daily_scan.name
}
