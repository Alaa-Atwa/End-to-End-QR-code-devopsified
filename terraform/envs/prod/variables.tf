variable "project_name" {
  type    = string
  default = "qr-code-app"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "app_bucket_name" {
  description = "Name of the existing S3 bucket the app writes QR codes to"
  type        = string
}