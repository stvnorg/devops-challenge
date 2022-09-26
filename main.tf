locals {
  candidate = var.candidate
}

module "networks" {
  source = "./modules/networks"

  network = {
    vpc = {
      cidr_block            = "172.16.0.0/16"
      enable_dns_support    = true
      enable_dns_hostnames  = true
      name                  = "the-vpc"
    }

    subnets = {
      the_public = {
        cidr_blocks = ["172.16.0.0/24", "172.16.1.0/24"]
      }
      the_private = {
        cidr_blocks = ["172.16.128.0/24", "172.16.129.0/24"]
      }
    }

    igw = {
      name = "the-igw"
    }

    eip = {
      the_nat_gw = {
        name = "ip-for-nat-gateway"
      }
    }

    nat_gateway = {
      name = "nat-gateway-for-private-subnet"
    }

    route_tables = {
      the_public = {
        name = "the-public-route-table"
      }
      the_nat_gw = {
        name = "the-nat-gateway-route-table"
      }
    }

    security_groups = {
      bastion = {
        name        = "allow-ssh-public"
        description = "Allow Access to Port 22 SSH from Public Internet"
      }
      load_balancer = {
        name        = "allow-http-https-public"
        description = "Allow Access to Port 80 (HTTP) and 443 (HTTPS) from Public Internet"
      }
      webserver = {
        name        = "allow-http-from-lb"
        description = "Allow HTTP Access from LoadBalancer and SSH Access from Bastion"
      }
    }
  }

  candidate = local.candidate
}

module "instances" {
  source = "./modules/instances"

  vpc = module.networks.the_vpc

  ec2 = {
    launch_template = {
      webservers = {
        name            = "nginx-webservers"
        instance_type   = "t3.micro"
        ebs = {
          volume_size = 10
          optimized   = true
        }
        monitoring = {
          enabled = true
        }
        network_interfaces = {
          subnet_id         = module.networks.the_private_subnets[0]
          security_groups   = [module.networks.webserver_sg]
        }
      }
    }

    autoscaling_group = {
      webservers = {
        desired_capacity    = 1
        min_size            = 1
        max_size            = 3
        vpc_zone_identifier = module.networks.the_private_subnets[0]
      }
    }

    lb = {
      webservers = {
        name            = "webservers-lb"
        security_groups = [module.networks.http_https_lb_sg]
        subnets         = module.networks.the_public_subnets[0]
        http_target_group = {
          name = "webserver-http-target-group"
        }
        http_lb_listener = {
          name = "webserver-http-lb-listener"
        }
      }
    }
  }

  candidate = local.candidate
}

output "lb_dns_name" {
  value = module.instances.lb_dns_name
}
