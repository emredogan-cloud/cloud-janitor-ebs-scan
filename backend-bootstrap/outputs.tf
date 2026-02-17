output "bucket_name" {
  value = aws_s3_bucket.state_bucket.id
}

output "dynamo_table" {
  value = aws_dynamodb_table.state_table.name
}