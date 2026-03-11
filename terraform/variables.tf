variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "ami_id" {
  type = string
}

variable "key_name" {
  type    = string
  default = null
}