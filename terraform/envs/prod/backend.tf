# terraform/envs/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "qr-code-app-tfstate-alaa-2026"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "qr-code-app-tf-locks"
    encrypt        = true
  }
}