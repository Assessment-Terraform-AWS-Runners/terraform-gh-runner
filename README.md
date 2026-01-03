# terraform-gh-runner

This repository contains Terraform code to provision an AWS EC2 instance as a **GitHub self-hosted runner**, along with a **monitoring script** to track CPU, memory, and disk usage.  

- **Terraform code**: Creates EC2, security group, and sets up environment.  
- **GitHub Workflow YAML**: Example workflow using the self-hosted runner.  
- **Monitoring script**: Bash script to check EC2 health in real-time.  

Simply apply the Terraform code to create the EC2, register the runner with GitHub using a token, and use the monitoring script to track resources.
