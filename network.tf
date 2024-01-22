resource "aws_vpc" "ec2_vpc" {
  cidr_block = "10.0.0.0/24" # 256 ips
  tags = {
    Name = "ec2-vpc"
  }
}
resource "aws_subnet" "ec2_public_a" {
  vpc_id                  = aws_vpc.ec2_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.ec2_vpc.cidr_block, 2, 0) # "10.0.0.0/26"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "ec2-public-subnet-a"
  }
}
resource "aws_subnet" "ec2_public_b" {
  vpc_id                  = aws_vpc.ec2_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.ec2_vpc.cidr_block, 2, 1) # "10.0.0.64/26" 
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "ec2-public-subnet-b"
  }
}
resource "aws_subnet" "ec2_private_a" {
  vpc_id                  = aws_vpc.ec2_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.ec2_vpc.cidr_block, 2, 2) # "10.0.0.128/26" 
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name = "ec2-private-subnet-a"
  }
}
resource "aws_internet_gateway" "ec2_igw" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "ec2-igw"
  }
}
resource "aws_route_table" "ec2_rt_public" {
  vpc_id = aws_vpc.ec2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2_igw.id
  }
  tags = {
    Name = "ec2-public-rt"
  }
}
resource "aws_route_table_association" "ec2_public_a" {
  subnet_id      = aws_subnet.ec2_public_a.id
  route_table_id = aws_route_table.ec2_rt_public.id
}
resource "aws_route_table_association" "ec2_public_b" {
  subnet_id      = aws_subnet.ec2_public_b.id
  route_table_id = aws_route_table.ec2_rt_public.id
}
resource "aws_eip" "ec2_ip" {
  domain = "vpc"
  tags = {
    Name = "ec2-nat-elastic-ip"
  }
}
resource "aws_nat_gateway" "ec2_nat_private_subnet" {
  allocation_id = aws_eip.ec2_ip.id
  subnet_id     = aws_subnet.ec2_public_a.id
  tags = {
    Name = "ec2-nat-private-subnet"
  }
}
resource "aws_route_table" "ec2_rt_private" {
  vpc_id = aws_vpc.ec2_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ec2_nat_private_subnet.id
  }
}
resource "aws_route_table_association" "ec2_private_a" {
  subnet_id      = aws_subnet.ec2_private_a.id
  route_table_id = aws_route_table.ec2_rt_private.id
}