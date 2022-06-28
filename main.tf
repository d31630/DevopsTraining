provider "aws" {
  
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Isolated Private Subnet"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.16/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Isolated Private Subnet2"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.16/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet2"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = "Public Subnet Route Table."
    }
}

resource "aws_route_table_association" "my_vpc_us_east_1a_public1" {
    subnet_id = aws_subnet.public1.id
    route_table_id = aws_route_table.my_public.id
}

resource "aws_route_table_association" "my_vpc_us_east_1a_public2" {
    subnet_id = aws_subnet.public2.id
    route_table_id = aws_route_table.my_public.id
}


resource "aws_route_table" "my_private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "Local Route Table for Isolated Private Subnet"
    }
}

resource "aws_route_table_association" "my_vpc_us_east_1a_private1" {
    subnet_id = aws_subnet.private1.id
    route_table_id = aws_route_table.my_private.id
}

resource "aws_route_table_association" "my_vpc_us_east_1a_private2" {
    subnet_id = aws_subnet.private2.id
    route_table_id = aws_route_table.my_private.id
}

resource "aws_eip" "ip1" {
  vpc      = true
  tags = {
    Name = "t4-elasticIP1"
  }
}
resource "aws_eip" "ip2" {
  vpc      = true
  tags = {
    Name = "t4-elasticIP2"
  }
}

resource "aws_nat_gateway" "nat-gateway1" {
  allocation_id = "${aws_eip.ip.id}"
  subnet_id     = "${aws_subnet.public1.id}"


  tags = {
    Name = "nat-gateway1"
  }
}

resource "aws_nat_gateway" "nat-gateway2" {
  allocation_id = "${aws_eip.ip.id}"
  subnet_id     = "${aws_subnet.public2.id}"


  tags = {
    Name = "nat-gateway2"
  }
}

resource "aws_route_table" "t4routeTable-2" {
  vpc_id = "${aws_vpc.main.id}"


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-gateway1.id}"
  }

  tags = {
    Name = "t4routeTable-2"
  }
}
 resource "aws_route_table_association" "associate2" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.t4routeTable-2.id
}

