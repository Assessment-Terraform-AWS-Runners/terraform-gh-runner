variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "create_ec2" {
  description = "Whether to create a new EC2 instance"
  type        = bool
  default     = true
}
