provider "aws" {
  region = "us-east-1"
}

# Create the Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description = "Demo Transit Gateway"
}

# Create VPCs
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev_vpc"
  }
}

resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "prod_vpc"
  }
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "test_vpc"
  }
}

# Create Subnets
resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "prod_subnet" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.1.1.0/24"
}

resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.2.1.0/24"
}

# Create Internet Gateway for dev VPC
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
}

# Create Transit Gateway Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_attachment" {
  subnet_ids         = [aws_subnet.dev_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.dev_vpc.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod_attachment" {
  subnet_ids         = [aws_subnet.prod_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.prod_vpc.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "test_attachment" {
  subnet_ids         = [aws_subnet.test_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.test_vpc.id
}

# Create Route Tables
resource "aws_route_table" "dev_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  route {
    cidr_block                = aws_vpc.prod_vpc.cidr_block
    transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
  }
}

resource "aws_route_table" "prod_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block                = aws_vpc.dev_vpc.cidr_block
    transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
  }
}

resource "aws_route_table" "test_rt" {
  vpc_id = aws_vpc.test_vpc.id
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "dev_rt_assoc" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.dev_rt.id
}

resource "aws_route_table_association" "prod_rt_assoc" {
  subnet_id      = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.prod_rt.id
}

resource "aws_route_table_association" "test_rt_assoc" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_rt.id
}

# Create Network ACLs
resource "aws_network_acl" "dev_nacl" {
  vpc_id = aws_vpc.dev_vpc.id

  egress {
    rule_no     = 100
    protocol    = "tcp"
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 65535
  }

  ingress {
    rule_no     = 100
    protocol    = "tcp"
    action      = "allow"
    cidr_block  = aws_vpc.prod_vpc.cidr_block
    from_port   = 0
    to_port     = 65535
  }

  ingress {
    rule_no     = 200
    protocol    = "tcp"
    action      = "deny"
    cidr_block  = aws_vpc.test_vpc.cidr_block
    from_port   = 0
    to_port     = 65535
  }
}

resource "aws_network_acl" "prod_nacl" {
  vpc_id = aws_vpc.prod_vpc.id

  egress {
    rule_no     = 100
    protocol    = "tcp"
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 65535
  }

  ingress {
    rule_no     = 100
    protocol    = "tcp"
    action      = "allow"
    cidr_block  = aws_vpc.dev_vpc.cidr_block
    from_port   = 0
    to_port     = 65535
  }

  ingress {
    rule_no     = 200
    protocol    = "tcp"
    action      = "deny"
    cidr_block  = aws_vpc.test_vpc.cidr_block
    from_port   = 0
    to_port     = 65535
  }
}

# Associate Network ACLs with Subnets
resource "aws_network_acl_association" "dev_nacl_assoc" {
  subnet_id      = aws_subnet.dev_subnet.id
  network_acl_id = aws_network_acl.dev_nacl.id
}

resource "aws_network_acl_association" "prod_nacl_assoc" {
  subnet_id      = aws_subnet.prod_subnet.id
  network_acl_id = aws_network_acl.prod_nacl.id
}
