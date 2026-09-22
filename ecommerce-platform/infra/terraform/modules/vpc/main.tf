# Production Modular VPC Module (3 AZs, Public, Private, Database Subnets, NAT Gateway)
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "environment" {
  type    = string
  default = "prod"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                        = "ecommerce-vpc-${var.environment}"
    "kubernetes.io/cluster/ecommerce-eks-${var.environment}" = "shared"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecommerce-igw-${var.environment}"
  }
}

# Public Subnets (For ALB & Edge)
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                                     = "ecommerce-public-${count.index + 1}"
    "kubernetes.io/role/elb"                                 = "1"
    "kubernetes.io/cluster/ecommerce-eks-${var.environment}" = "shared"
  }
}

# Private Subnets (For EKS Nodes & Karpenter Pods)
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                                     = "ecommerce-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"                        = "1"
    "karpenter.sh/discovery"                                 = "ecommerce-eks-${var.environment}"
    "kubernetes.io/cluster/ecommerce-eks-${var.environment}" = "shared"
  }
}

# Elastic IP & NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "ecommerce-nat-gw-${var.environment}"
  }
}

# Route Tables & Associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}
