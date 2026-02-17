terraform {
  backend "s3" {
    bucket = "cloud-janitor82ee1d0c"
    key = "cloud-janitor-ebs-tfstate-file/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "cloud-janitor-state-table"
    encrypt = true
  }
}