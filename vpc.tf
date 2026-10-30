###############################################################################################################
# VPC
###############################################################################################################
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-vpc"
    }
  )
}
###############################################################################################################
# INTERNET GATEWAY
###############################################################################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-igw"
    }
  )
}
###############################################################################################################
# PUBLIC SUBNETS
###############################################################################################################
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-public-${local.az_names[count.index]}"
    }
  )
}
###############################################################################################################
# PRIVATE SUBNETS
###############################################################################################################
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  #map_public_ip_on_launch = true
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-private-${local.az_names[count.index]}"
    }
  )
}
###############################################################################################################
# DATABASE SUBNETS
###############################################################################################################
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  #map_public_ip_on_launch = true
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-database-${local.az_names[count.index]}"
    }
  )
}
###############################################################################################################
# PUBLIC ROUTE TABLE
###############################################################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-public_rt"
    }
  )
}
###############################################################################################################
# PRIVATE ROUTE TABLE
###############################################################################################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-private_rt"
    }
  )
}
###############################################################################################################
# PRIVATE ROUTE TABLE
###############################################################################################################
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-database_rt"
    }
  )
}
###############################################################################################################
# PUBLIC ROUTE 
###############################################################################################################
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}
###############################################################################################################
# PRIVATE ROUTE 
###############################################################################################################
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}
###############################################################################################################
# DATABASE ROUTE 
###############################################################################################################
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}
###############################################################################################################
# ELASTIC IP
###############################################################################################################
resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-eip"
    }
  )
}
###############################################################################################################
# NAT GATEWAY
###############################################################################################################
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.nat_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-eip"
    }
  )
  depends_on = [aws_internet_gateway.main]
}
###############################################################################################################
# PUBLIC ROUTE TABLE ASSOCIATION
###############################################################################################################
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
###############################################################################################################
# PRIVATE ROUTE TABLE ASSOCIATION
###############################################################################################################
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
###############################################################################################################
# DATABASE ROUTE TABLE ASSOCIATION
###############################################################################################################
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
###############################################################################################################