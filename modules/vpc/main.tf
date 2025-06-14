resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      "Name" = var.vpc_name
    },
    var.tags
  )
}

# Public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = "${var.vpc_name}-public-${var.azs[count.index]}"
      "kubernetes.io/role/elb" = "1"
    },
    var.tags
  )
}

# Private subnets for Kubernetes
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = "${var.vpc_name}-private-${var.azs[count.index]}"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.tags
  )
}

# Multus subnets for AZ1
resource "aws_subnet" "multus_az1" {
  for_each = var.multus_subnets_az1

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[0]

  tags = merge(
    {
      "Name" = "${var.vpc_name}-multus-${each.key}-${var.azs[0]}"
    },
    var.tags
  )
}

# Multus subnets for AZ2
resource "aws_subnet" "multus_az2" {
  for_each = var.multus_subnets_az2

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[1]

  tags = merge(
    {
      "Name" = "${var.vpc_name}-multus-${each.key}-${var.azs[1]}"
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.vpc_name}-igw"
    },
    var.tags
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  domain = "vpc"

  tags = merge(
    {
      "Name" = "${var.vpc_name}-nat-eip-${count.index}"
    },
    var.tags
  )
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      "Name" = "${var.vpc_name}-nat-gw-${count.index}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.vpc_name}-public-rt"
    },
    var.tags
  )
}

# Route to Internet Gateway for public subnets
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route tables for private subnets
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.vpc_name}-private-rt-${count.index}"
    },
    var.tags
  )
}

# Routes to NAT Gateway for private subnets
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

# Route tables for multus subnets in AZ1
resource "aws_route_table" "multus_az1" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.vpc_name}-multus-rt-${var.azs[0]}"
    },
    var.tags
  )
}

# Route to NAT Gateway for multus subnets in AZ1
resource "aws_route" "multus_az1_nat_gateway" {
  route_table_id         = aws_route_table.multus_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : 0].id
}

# Route table associations for multus subnets in AZ1
resource "aws_route_table_association" "multus_az1" {
  for_each = aws_subnet.multus_az1

  subnet_id      = each.value.id
  route_table_id = aws_route_table.multus_az1.id
}

# Route tables for multus subnets in AZ2
resource "aws_route_table" "multus_az2" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.vpc_name}-multus-rt-${var.azs[1]}"
    },
    var.tags
  )
}

# Route to NAT Gateway for multus subnets in AZ2
resource "aws_route" "multus_az2_nat_gateway" {
  route_table_id         = aws_route_table.multus_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : 1].id
}

# Route table associations for multus subnets in AZ2
resource "aws_route_table_association" "multus_az2" {
  for_each = aws_subnet.multus_az2

  subnet_id      = each.value.id
  route_table_id = aws_route_table.multus_az2.id
}