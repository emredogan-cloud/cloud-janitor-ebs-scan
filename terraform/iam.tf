
resource "aws_iam_role" "lambda_role" {
  name = "cloud-janitor-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "cloudwatch_logs_write" {
  name        = "cloud-janitor-logs-write"
  description = "Allow Lambda to write logs to CloudWatch Logs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowWriteLogs"
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}


resource "aws_iam_policy" "ec2_describe_volumes" {
  name        = "cloud-janitor-ec2-describe"
  description = "Allow describing EBS volumes (and regions) for orphan scan."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowDescribeVolumes"
      Effect = "Allow"
      Action = [
        "ec2:DescribeVolumes",
        "ec2:DescribeRegions"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

resource "aws_iam_role_policy_attachment" "attach_ec2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ec2_describe_volumes.arn
}
