# Terraform AWS Load Balancer + Target Group + Auto Scaling Group

This project provisions a simple highly available web infrastructure in AWS using Terraform.

It deploys:
- a default VPC
- two default subnets in different Availability Zones
- a security group for HTTP, HTTPS, and SSH
- an EC2 Launch Template
- an Auto Scaling Group with 2 web instances
- an Application Load Balancer
- a Target Group and Listener
- an imported SSH key pair

Each EC2 instance installs Apache via `user_data` and serves a simple HTML page.

## Architecture

The infrastructure includes:

- **AWS Default VPC**
- **2 Default Subnets** in different Availability Zones
- **Security Group** allowing:
  - SSH (`22`)
  - HTTP (`80`)
  - HTTPS (`443`)
- **Launch Template** for EC2 instances
- **Auto Scaling Group** with:
  - minimum: `2`
  - desired: `2`
  - maximum: `4`
- **Application Load Balancer**
- **Target Group**
- **Listener** on port `80`

Traffic flow:

`User -> Application Load Balancer -> Target Group -> EC2 instances`

## Project Goal

The goal of this project is to demonstrate practical Infrastructure as Code skills using Terraform and AWS.

This project shows how to:
- provision cloud infrastructure with Terraform
- use a Launch Template for EC2 configuration
- attach instances to an Auto Scaling Group
- distribute traffic through an Application Load Balancer
- configure health checks
- bootstrap web servers with `user_data`

## Technologies Used

- **Terraform**
- **AWS**
- **EC2**
- **Application Load Balancer**
- **Auto Scaling Group**
- **Launch Template**
- **Security Groups**
- **Apache2**
- **Ubuntu 24.04 Minimal AMI**

## File Structure

```text
.
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── .terraform.lock.hcl
└── README.md
