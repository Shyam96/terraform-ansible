variable "aws_region" {
  default = "us-west-2"
}

variable "namespace" {
  default = "test"
}

variable "aws_amis" {
  default = "ami-5fd34f27"
}

variable "vpc_id" {
  default = "vpc-xxxxxxx"
}

variable "private_subnets" {
  default = "subnet-1,subnet-2,subnet-3"
}