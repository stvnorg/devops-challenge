locals {
  vars = {
    candidate = var.candidate
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#
# Create the launch_template to spin-up EC2 instances 
#
resource "aws_launch_template" "webservers" {
  name      = var.ec2.launch_template.webservers.name

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.ec2.launch_template.webservers.ebs.volume_size
    }
  }

  ebs_optimized = var.ec2.launch_template.webservers.ebs.optimized

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.ec2.launch_template.webservers.instance_type

  monitoring {
    enabled = var.ec2.launch_template.webservers.monitoring.enabled
  }

  network_interfaces {
    delete_on_termination = true
    subnet_id = var.ec2.launch_template.webservers.network_interfaces.subnet_id[0]
    security_groups = var.ec2.launch_template.webservers.network_interfaces.security_groups
  }

  user_data = base64encode(templatefile("${path.module}/scripts/deploy_nginx.sh", local.vars))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = var.ec2.launch_template.webservers.name
      managedby = local.managed_by
      Candidate = var.candidate
    }
  }

  key_name = "deployer"
}
