terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.25.0"
    }
  }
}


# ----------------------------------------------------------------------------- locals
locals {
  subnets_char = upper(substr(var.availability_zone, -1, 1))
  private_snet_count = var.exists_private_snet ? 1 : 0
  isolated_snet_count = var.exists_isolated_snet ? 1 : 0
  all_ips_cidr_block = "0.0.0.0/0"
}


# ----------------------------------------------------------------------------- public area
resource "aws_subnet" "public_snet" {
  availability_zone = var.availability_zone
  vpc_id = var.vpc_id
  cidr_block = var.public_cidr_block
  map_public_ip_on_launch = true
  tags = {Name = "${var.vpc_elevel_name_prefix}-public-snet-${local.subnets_char}"}
}

resource "aws_route_table" "public_snet_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = local.all_ips_cidr_block
    gateway_id = var.vpc_internet_gateway_id
  }
  tags = {Name = "${var.vpc_elevel_name_prefix}-public-snet-${local.subnets_char}-rt"}
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id = aws_subnet.public_snet.id
  route_table_id = aws_route_table.public_snet_rt.id
  depends_on = [aws_subnet.public_snet, aws_route_table.public_snet_rt]
}

resource "aws_eip" "nat_eip" {
  count = local.private_snet_count
  domain = "vpc"
  tags = {Name = "${var.vpc_elevel_name_prefix}-public-snet-${local.subnets_char}-nat-eip"} 
}

resource "aws_nat_gateway" "nat_for_private" {
  count = local.private_snet_count
  subnet_id = aws_subnet.public_snet.id
  connectivity_type = "public"
  allocation_id = aws_eip.nat_eip[0].id
  tags = {Name = "${var.vpc_elevel_name_prefix}-public-snet-${local.subnets_char}-nat"}
}

# ----------------------------------------------------------------------------- private area
resource "aws_subnet" "private_snet" {
  count = local.private_snet_count
  availability_zone = var.availability_zone
  vpc_id = var.vpc_id
  cidr_block = var.private_cidr_block
  map_public_ip_on_launch = false
  tags = {Name = "${var.vpc_elevel_name_prefix}-private-snet-${local.subnets_char}"}
}

resource "aws_route_table" "private_snet_rt" {
  count = local.private_snet_count
  vpc_id = var.vpc_id
  route {
    cidr_block = local.all_ips_cidr_block
    nat_gateway_id = aws_nat_gateway.nat_for_private[0].id
  }
  tags = {Name = "${var.vpc_elevel_name_prefix}-private-snet-${local.subnets_char}-rt"}
}

resource "aws_route_table_association" "private_rt_association" {
  count = local.private_snet_count
  subnet_id = aws_subnet.private_snet[0].id
  route_table_id = aws_route_table.private_snet_rt[0].id
  depends_on = [aws_subnet.private_snet, aws_route_table.private_snet_rt]
}


# ----------------------------------------------------------------------------- isolated area
resource "aws_subnet" "isolated_snet" {
  count = local.isolated_snet_count
  availability_zone = var.availability_zone
  vpc_id = var.vpc_id
  cidr_block = var.isolated_cidr_block
  map_public_ip_on_launch = false
  tags = {Name = "${var.vpc_elevel_name_prefix}-isolated-snet-${local.subnets_char}"}
}

resource "aws_route_table" "isolated_snet_rt" {
  count = local.isolated_snet_count
  vpc_id = var.vpc_id
  tags = {Name = "${var.vpc_elevel_name_prefix}-isolated-snet-${local.subnets_char}-rt"}
}

resource "aws_route_table_association" "isolated_rt_association" {
  count = local.isolated_snet_count
  subnet_id = aws_subnet.isolated_snet[0].id 
  route_table_id = aws_route_table.isolated_snet_rt[0].id
  depends_on = [aws_subnet.isolated_snet, aws_route_table.isolated_snet_rt]
}