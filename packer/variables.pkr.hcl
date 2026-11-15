variable "aws_region" {
  description = "AWS region in which to build the Ubuntu AMI."
  type        = string
}

variable "instance_type" {
  description = "Temporary EC2 instance type used to build the AMI."
  type        = string
}

variable "ami_name_prefix" {
  description = "Prefix used for the resulting AMI name."
  type        = string
}
