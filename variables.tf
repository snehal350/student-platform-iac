variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "student-platform"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "key_name" {
  type    = string
  default = "student-aws-key"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/student-aws-key.pub"
}

variable "private_key_path" {
  type    = string
  default = "~/.ssh/student-aws-key"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "Controller public IP in CIDR form, e.g. 1.2.3.4/32"
}
