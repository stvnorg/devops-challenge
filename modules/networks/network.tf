#
# Create the VPC
#
resource "aws_vpc" "the_vpc" {  
  cidr_block            = var.network.vpc.cidr_block
  enable_dns_support    = var.network.vpc.enable_dns_support
  enable_dns_hostnames  = var.network.vpc.enable_dns_hostnames

  tags = {
    Name        = var.network.vpc.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Create the public_subnets
#
resource "aws_subnet" "the_public" {
  count             = length(var.network.subnets.the_public.cidr_blocks)
  vpc_id            = aws_vpc.the_vpc.id
  cidr_block        = var.network.subnets.the_public.cidr_blocks[count.index]
  availability_zone = count.index % 2 == 0 ? "us-east-2a" : "us-east-2b"

  tags = {
    Name        = "public-subnet-${count.index}"
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
#
#
resource "aws_subnet" "the_private" {
  count         = length(var.network.subnets.the_private.cidr_blocks)
  vpc_id        = aws_vpc.the_vpc.id
  cidr_block    = var.network.subnets.the_private.cidr_blocks[count.index]
  availability_zone = count.index % 2 == 0 ? "us-east-2a" : "us-east-2b"

  tags = {
    Name        = "private-subnet-${count.index}"
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Create the internet_gateway
#
resource "aws_internet_gateway" "the_igw" {
  vpc_id    = aws_vpc.the_vpc.id
  
  tags = {
    Name        = var.network.igw.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Create the public_route_table for the public_subnet
#
resource "aws_route_table" "the_public" {
  vpc_id    = aws_vpc.the_vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.the_igw.id
  }

  tags = {
    Name        = var.network.route_tables.the_public.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Associate the public_route_table to the public_subnet
#
resource "aws_route_table_association" "the_public" {
  count             = length(var.network.subnets.the_public.cidr_blocks)
  subnet_id         = aws_subnet.the_public[count.index].id
  route_table_id    = aws_route_table.the_public.id
  
  depends_on = [
    aws_subnet.the_public
  ]
}

#
# Reserve elastic_iP for the nat_gateway
#
resource "aws_eip" "the_nat_gw" {
  tags = {
    Name        = var.network.eip.the_nat_gw.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Create the nat_gateway, place the gw in the public-subnet-0
#
resource "aws_nat_gateway" "the_nat_gw" {
  allocation_id = aws_eip.the_nat_gw.id
  subnet_id     = aws_subnet.the_public[0].id

  tags = {
    Name        = var.network.nat_gateway.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }

  depends_on = [
    aws_internet_gateway.the_igw
  ]
}

#
# Create the nat_route_table for the nat_gateway
#
resource "aws_route_table" "the_nat_gw" {
  vpc_id    = aws_vpc.the_vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.the_nat_gw.id
  }

  tags = {
    Name        = var.network.route_tables.the_nat_gw.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Associate the nat_gw_route_table to the private_subnet
#
resource "aws_route_table_association" "the_nat_gw" {
  count             = length(var.network.subnets.the_private.cidr_blocks)
  subnet_id         = aws_subnet.the_private[count.index].id
  route_table_id    = aws_route_table.the_nat_gw.id

  depends_on = [
    aws_subnet.the_private
  ]
}
