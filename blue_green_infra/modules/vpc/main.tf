# vpc for blue green deployment

resource "aws_vpc" "blue_green_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.blue_green_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"  
  tags = {
    Name = "${var.project_name}-public-subnet-1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.blue_green_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"  
    tags = {
        Name = "${var.project_name}-public-subnet-2"
    }   
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.blue_green_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
    tags = {
        Name = "${var.project_name}-private-subnet-1"
    }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.blue_green_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
    tags = {
        Name = "${var.project_name}-private-subnet-2"
    }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.blue_green_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1c"
    tags = {
        Name = "${var.project_name}-private-subnet-3"
    }  
}

resource "aws_subnet" "private_subnet_4" {
  vpc_id            = aws_vpc.blue_green_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1d"
    tags = {
        Name = "${var.project_name}-private-subnet-4"
    }
}

resource "aws_internet_gateway" "blue_green_igw" {
  vpc_id = aws_vpc.blue_green_vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "blue_green_public_rt" {
  vpc_id = aws_vpc.blue_green_vpc.id
  route {
    cidr_block = "0.0.0/0"
    gateway_id = aws_internet_gateway.blue_green_igw.id
  }
    tags = {
        Name = "${var.project_name}-public-rt"
    }
}

resource "aws_route_table" "blue_green_private_rt" {
  vpc_id = aws_vpc.blue_green_vpc.id
    tags = {
        Name = "${var.project_name}-private-rt"
    }
}

resource "aws_route_table" "blue_green_private_db_rt" {
  vpc_id = aws_vpc.blue_green_vpc.id
    tags = {
        Name = "${var.project_name}-db-private-rt"
    }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.blue_green_public_rt.id
}
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.blue_green_public_rt.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.blue_green_private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.blue_green_private_rt.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.blue_green_private_db_rt.id
}

resource "aws_route_table_association" "private_subnet_4_association" {
  subnet_id      = aws_subnet.private_subnet_4.id
  route_table_id = aws_route_table.blue_green_private_db_rt.id
}
