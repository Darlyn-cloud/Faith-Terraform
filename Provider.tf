# Configure the AWS Provider

provider "aws" {
  region = "eu-west-2"
}


# Networking for Grace IT Group

resource "aws_vpc" "Prod-VPC" {

  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Prod-VPC "
  }
}

# Public Subnet 1

resource "aws_subnet" "Prod-pub-sub-1" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.1.0/24"
availability_zone = "eu-west-2a"
  tags = {
    Name = "Prod-pub-sub-1"
  }
}

resource "aws_subnet" "Prod-pub-sub-2" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.2.0/24"
availability_zone = "eu-west-2a"
  tags = {
    Name = "Prod-pub-sub-2"
  }
}



# Private Subnet

resource "aws_subnet" "Prod-priv-subnet-1" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.3.0/24"
availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-subnet-1"
  }
}


 resource "aws_subnet" "Prod-priv-subnet-2" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.4.0/24"
availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-subnet-2"
  }
}

 

 # Public RT

resource "aws_route_table" "Prod-pub-RT" {
  vpc_id = aws_vpc.Prod-VPC.id

  tags = {
    Name = "Prod-pub-Route-table"
  }
}

# Associte public subnet to public RT

 resource "aws_route_table_association" "Prod-Route-Table-Assoc-to-Pub-subnet" {
  subnet_id      = aws_subnet.Prod-pub-sub-1.id
  route_table_id = aws_route_table.Prod-pub-RT.id
}

 resource "aws_route_table_association" "Prod-Rout-Table-Assoc-to-Pub-subnet" {
  subnet_id      = aws_subnet.Prod-pub-sub-2.id
  route_table_id = aws_route_table.Prod-pub-RT.id
}


# Private RT

resource "aws_route_table" "Prod-priv-RT" {
  vpc_id = aws_vpc.Prod-VPC.id

  tags = {
    Name = "Prod-priv-RT"
  }
}

# Associte private subnet to private RT

 resource "aws_route_table_association" "Prod-route-table-Assoc-to-Pub-subnet" {
  subnet_id      = aws_subnet.Prod-priv-subnet-1.id
  route_table_id = aws_route_table.Prod-priv-RT.id

}
  
 resource "aws_route_table_association" "Prod-rout-table-Assoc-to-Pub-subnet" {
  subnet_id      = aws_subnet.Prod-priv-subnet-2.id
  route_table_id = aws_route_table.Prod-priv-RT.id

}

# Internet Gateway 

resource "aws_internet_gateway" "Prod-Igw" {
  vpc_id = aws_vpc.Prod-VPC.id

  tags = {
    Name = "Prod-VPC"
  }
}

# Internet Gateway Route Table Association
resource "aws_route_table_association" "Prod-Igw-assoc-Prod-pub-RT" {
 gateway_id     = aws_internet_gateway.Prod-Igw.id
 route_table_id = aws_route_table.Prod-pub-RT.id
}


# Create Elastic IP Address

resource "aws_eip" "Prod-EIP" {
  tags = {
    Name = "Prod-EIP"
  }
}


# Create NAT Gateway

resource "aws_nat_gateway" "Prod-Nat-Gateway" {
  allocation_id = aws_eip.Prod-EIP.id
  subnet_id     = aws_subnet.Prod-pub-sub-1.id

  tags = {
    Name = "Prod-Nat-Gateway"
  }


}




# NAT Associate with Priv route

resource "aws_route" "Prod-Nat-Gateway-assoc-Prod-priv-RT" {
  route_table_id = aws_route_table.Prod-priv-RT.id
  gateway_id = aws_nat_gateway.Prod-Nat-Gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

