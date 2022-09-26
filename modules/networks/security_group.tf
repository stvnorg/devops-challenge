#
# HTTP and HTTPS Security Group for the LoadBalancer
# Allow Port 80 and 443 from 0.0.0.0/0
#
resource "aws_security_group" "http_https_lb" {
  name          = var.network.security_groups.load_balancer.name
  description   = var.network.security_groups.load_balancer.description
  vpc_id        = aws_vpc.the_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = var.network.security_groups.load_balancer.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Security group for the bastion instance
# Allow SSH port 22 from 0.0.0.0/0
#
resource "aws_security_group" "bastion" {
  name          = var.network.security_groups.bastion.name
  description   = var.network.security_groups.bastion.description
  vpc_id        = aws_vpc.the_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = var.network.security_groups.bastion.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Security group for the NGiNX Web Server
# Allow SSH port 22 from bastion instances,
# and allow HTTP/HTTPS port 80/443 from LoadBalancer
#
resource "aws_security_group" "webserver" {
  name          = var.network.security_groups.webserver.name
  description   = var.network.security_groups.webserver.description
  vpc_id        = aws_vpc.the_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [
      aws_security_group.bastion.id
    ]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [
      aws_security_group.http_https_lb.id
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = var.network.security_groups.webserver.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}
