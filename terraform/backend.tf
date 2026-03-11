terraform {
  backend "s3" {
    bucket = "chr-devops-terraform-state-2026"
    key    = "app-infrastructure/terraform.tfstate"
    region = "eu-central-1"
  }
}