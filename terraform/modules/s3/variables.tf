variable "project_name" {
  type = string
}

variable "bucket_name" {
  description = "Name of the existing S3 bucket used by the app"
  type        = string
}