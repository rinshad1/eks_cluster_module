#######modules/vpc/main.tf
resource "aws_vpc" "cloudquick" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.instance_tenancy
  tags = {
    Name = var.tags
  }
}

resource "aws_internet_gateway" "cloudquick_gw" {
  vpc_id = aws_vpc.cloudquick.id

  tags = {
    Name = var.tags
  }
}


data "aws_availability_zones" "available" {
}


resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = 2
}

resource "aws_subnet" "public_cloudquick_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.cloudquick.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = var.tags
  }
}

resource "aws_eip" "natgateway_eip" {
  domain = "vpc"
  tags = {
    Name = "eks-cluster-EIP"
  }
}

resource "aws_nat_gateway" "cloudquick_nat" {
  allocation_id = aws_eip.natgateway_eip.id
  subnet_id     = aws_subnet.public_cloudquick_subnet[0].id

  tags = {
    Name = "eks-cluster-NAT"
  }

}

resource "aws_subnet" "private_cloudquick_subnet" {
  count             = var.private_sn_count
  vpc_id            = aws_vpc.cloudquick.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]
  tags = {
    Name = var.tags2
  }
}

resource "aws_route_table" "internal_cloudquick_public" {
  vpc_id = aws_vpc.cloudquick.id
  route {
    cidr_block = var.rt_route_cidr_block
    gateway_id = aws_internet_gateway.cloudquick_gw.id
  }
  tags = {
    Name = var.tags
  }
}

resource "aws_route_table" "internal_cloudquick_private" {
  vpc_id = aws_vpc.cloudquick.id
  route {
    cidr_block     = var.rt_route_cidr_block
    nat_gateway_id = aws_nat_gateway.cloudquick_nat.id
  }
  tags = {
    Name = var.tags2
  }
}

resource "aws_route_table_association" "public" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_cloudquick_subnet[count.index].id
  route_table_id = aws_route_table.internal_cloudquick_public.id
}

resource "aws_route_table_association" "private" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.private_cloudquick_subnet[count.index].id
  route_table_id = aws_route_table.internal_cloudquick_private.id
}
