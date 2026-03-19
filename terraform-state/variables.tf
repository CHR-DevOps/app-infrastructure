variable "aws_region" {
  description = "AWS region that hosts the Terraform state bucket."
  type        = string
  default     = "eu-central-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name used for Terraform remote state."
  type        = string
  default     = "chr-devops-terraform-s3-state"
}

variable "project" {
  description = "Project tag applied to the state bucket."
  type        = string
  default     = "chr-devops"
}
