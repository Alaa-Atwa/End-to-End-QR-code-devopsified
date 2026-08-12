variable "project_name" {
  type = string
}

variable "repository_names" {
  description = "Names of ECR repositories to manage"
  type        = list(string)
}