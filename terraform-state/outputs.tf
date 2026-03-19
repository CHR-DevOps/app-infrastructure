output "aws_region" {
  description = "AWS region where the Terraform state bucket is deployed."
  value       = var.aws_region
}

output "state_bucket_name" {
  description = "Name of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}
