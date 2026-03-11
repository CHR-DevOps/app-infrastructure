variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "ami_id" {
  type = string
  default = "ami-01f79b1e4a5c64257"
}

variable "key_name" {
  type    = string
  default = null
}