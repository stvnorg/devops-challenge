# DevOps Challenge

Terraform repo for a code-challenge and learning

### Overview

This repo contains module to launch AWS resources as below:
- Full VPC with all necessary components:
  > - 2 Public and 2 Private subnets
  > - Public and Private route table
  > - Internet Gateway
  > - NAT Gateway
  > - Subnet Associations in Route Tables
- SSH and HTTP Protocol security groups for EC2 Instances
- HTTP and HTTPS Protocol security groups for LoadBalancer
- EC2 Launch Template
- Autoscaling Group
- User Data to configure NGiNX web server
- Application LoadBalancer

### Output

Upon the successful execution of the `terraform apply` and all resources has been created, the module will print out the `ALB DNS Name`

### AWS Region

By default the resources will be created in the AWS `us-east-2` (Ohio) region

### How to Run It
```bash
$ terraform init
$ terraform plan -var "candidate=<YOUR_NAME>"
$ terraform apply -var "candidate=<YOUR_NAME>"
```

The `candidate` variable is for the resource taggings
