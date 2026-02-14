################################################################################
# Data Sources
################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = "${var.name}-vpc"
  }
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route" "private_nat" {
  count = var.create_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name}-public-${count.index}"
  }
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public_internet" {
  count = var.create_internet_gateway && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.nat_gateway_subnet_index].id

  tags = {
    Name = "${var.name}-nat"
  }
}
