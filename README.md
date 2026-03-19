# Infrastructure

This repository now separates Terraform state bootstrap from the application infrastructure:

- `terraform-state/` creates and protects the S3 bucket used for Terraform remote state.
- `terraform/` provisions the actual application infrastructure and consumes that bucket as its backend.

## Recommended workflow

1. Bootstrap the remote-state bucket once:

```bash
cd terraform-state
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

If the bucket already exists in AWS and you are setting this up on a new machine, import it into this dedicated root instead of creating it again:

```bash
cd terraform-state
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform import aws_s3_bucket.terraform_state chr-devops-terraform-s3-state
terraform import aws_s3_bucket_versioning.terraform_state chr-devops-terraform-s3-state
terraform import aws_s3_bucket_server_side_encryption_configuration.terraform_state chr-devops-terraform-s3-state
terraform import aws_s3_bucket_public_access_block.terraform_state chr-devops-terraform-s3-state
```

2. Configure the main infrastructure backend:

```bash
cd ../terraform
cp backend.prod.hcl.example backend.prod.hcl
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.prod.hcl
terraform plan
terraform apply
```

## Why this split matters

Keeping the state bucket in its own Terraform root avoids the chicken-and-egg problem where infrastructure would need a backend bucket that it also tries to manage. It also lets you protect the state bucket with `prevent_destroy` and manage backend settings per environment without hardcoding them in the main stack.
