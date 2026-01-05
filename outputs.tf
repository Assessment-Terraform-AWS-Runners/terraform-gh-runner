output "ec2_public_ips" {
  description = "Public IPs of GitHub Runner EC2 instances"
  value = aws_instance.gh_runner[*].public_ip
}
