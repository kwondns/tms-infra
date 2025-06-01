resource "aws_vpc" "tms_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "tms-VPC"
  }
}

resource "aws_subnet" "tms_public_subnet_a" {
  vpc_id                  = aws_vpc.tms_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az_a
  map_public_ip_on_launch = true
  tags = { Name = "tms_public_subnet_a" }
}

resource "aws_subnet" "tms_public_subnet_b" {
  vpc_id                  = aws_vpc.tms_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.az_b
  map_public_ip_on_launch = true
  tags = { Name = "tms_public_subnet_b", Status = "not used" }
}

resource "aws_subnet" "tms_public_subnet_c" {
  vpc_id                  = aws_vpc.tms_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.az_c
  map_public_ip_on_launch = true
  tags = { Name = "tms_public_subnet_c" }
}

resource "aws_subnet" "tms_public_subnet_d" {
  vpc_id                  = aws_vpc.tms_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = var.az_d
  map_public_ip_on_launch = true
  tags = { Name = "tms_public_subnet_d", Status = "not used" }
}

# resource "aws_subnet" "tms_private_subnet_a" {
#   vpc_id                  = aws_vpc.tms_vpc.id
#   cidr_block              = "10.0.5.0/24"
#   availability_zone       = var.az_a
#   map_public_ip_on_launch = false
#   tags = { Name = "tms_private_subnet_a" }
# }
# resource "aws_subnet" "tms_private_subnet_c" {
#   vpc_id                  = aws_vpc.tms_vpc.id
#   cidr_block              = "10.0.6.0/24"
#   availability_zone       = var.az_c
#   map_public_ip_on_launch = false
#   tags = { Name = "tms_private_subnet_c", Status = "not used" }
# }
#
resource "aws_internet_gateway" "tms_ig" {
  vpc_id = aws_vpc.tms_vpc.id
  tags = { Name = "tms_ig" }
}

# # 추후 증설 필요 각 public 서브넷에 맞도록
# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

# # 추후 증설 필요 각 public 서브넷에 맞도록
# resource "aws_nat_gateway" "tms_subnet_nat" {
#   subnet_id     = aws_subnet.tms_public_subnet_a.id
#   allocation_id = aws_eip.nat.id
#   tags = { Name = "tms_subnet_nat" }
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tms_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tms_ig.id
  }
  tags = { Name = "tms_public_route_table" }
}

resource "aws_route_table_association" "public_a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.tms_public_subnet_a.id
}
resource "aws_route_table_association" "public_b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.tms_public_subnet_b.id
}
resource "aws_route_table_association" "public_c" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.tms_public_subnet_c.id
}
resource "aws_route_table_association" "public_d" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.tms_public_subnet_d.id
}

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.tms_vpc.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.tms_subnet_nat.id
#   }
#   tags = { Name = "tms_private_route_table" }
# }
#
# resource "aws_route_table_association" "private_a" {
#   route_table_id = aws_route_table.private.id
#   subnet_id      = aws_subnet.tms_private_subnet_a.id
# }
#
# resource "aws_route_table_association" "private_c" {
#   route_table_id = aws_route_table.private.id
#   subnet_id      = aws_subnet.tms_private_subnet_c.id
# }
