variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "ami_id" {
  type = string
  default = "ami-0a5b5c0ea66ec560d"
}

variable "key_name" {
  type    = string
  default = null
}