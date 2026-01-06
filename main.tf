# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets from default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "gh_runner_sg" {
  name        = "gh-runner-sg"
  description = "Security group for GitHub Runner EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "github-runner-sg"
  }
}

resource "aws_instance" "gh_runner" {
  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.gh_runner_sg.id]

  tags = {
    Name = "github-runner-ec2-${count.index + 1}"
  }
}

resource "null_resource" "copy_scripts" {
  count = length(aws_instance.gh_runner)

  depends_on = [aws_instance.gh_runner]

  # Create scripts directory first
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ec2-user/scripts"
    ]
  }

  # Copy install_runner.sh
  provisioner "file" {
    source      = "${path.module}/scripts/install_runner.sh"
    destination = "/home/ec2-user/scripts/install_runner.sh"
  }

  # Copy monitor_ec2.sh
  provisioner "file" {
    source      = "${path.module}/scripts/monitor_ec2.sh"
    destination = "/home/ec2-user/scripts/monitor_ec2.sh"
  }

  # Make scripts executable
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/scripts/install_runner.sh",
      "chmod +x /home/ec2-user/scripts/monitor_ec2.sh"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.gh_runner[count.index].public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }
}

# resource "null_resource" "install_runners" {
#   count = var.install_runners ? 1 : 0

#   depends_on = [aws_instance.gh_runner]

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/install_runner.sh",
#       "sed -i 's/\r$//' /tmp/install_runner.sh",
#       "sudo bash /tmp/install_runner.sh '${var.github_repo_url}' '${var.github_runner_token}' '${var.runner_count}'"
#     ]
#   }

#   connection {
#     type        = "ssh"
#     host        = aws_instance.gh_runner[0].public_ip
#     user        = "ec2-user"
#     private_key = file(var.private_key_path)
#   }
# }
