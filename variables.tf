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

variable "install_runners" {
  description = "Install GitHub runners on the EC2 instance"
  type        = bool
  default     = false
}

variable "github_repo_url" {
  description = "GitHub repo/org URL"
  type        = string
}

variable "github_runner_token" {
  description = "GitHub runner registration token"
  type        = string
  sensitive   = true
}

variable "runner_count" {
  description = "Number of runners to install"
  type        = number
  default     = 1
}

variable "private_key_path" {
  description = "Path to private key for SSH"
  type        = string
}
