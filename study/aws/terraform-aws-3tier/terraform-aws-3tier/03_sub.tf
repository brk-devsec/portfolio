resource "aws_subnet" "bat_a" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.0.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "bat-a"
  }
}

resource "aws_subnet" "nat_a" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.1.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "nat-a"
  }
}

resource "aws_subnet" "web_a" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.2.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "web-a"
  }
}

resource "aws_subnet" "web_c" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.3.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "web-c"
  }
}

resource "aws_subnet" "was_a" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.4.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "was-a"
  }
}

resource "aws_subnet" "was_c" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.5.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "was-c"
  }
}

resource "aws_subnet" "db_a" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.6.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "db-a"
  }
}

resource "aws_subnet" "db_c" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.7.0/24"
  availability_zone                           = "ap-northeast-2c"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "db-c"
  }
}

resource "aws_subnet" "load_a" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.8.0/24"
  availability_zone                           = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "load-a"
  }
}

resource "aws_subnet" "load_c" {
  vpc_id                                      = aws_vpc.brkim_vpc.id
  cidr_block                                  = "10.0.9.0/24"
  availability_zone                           = "ap-northeast-2c"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "load-c"
  }
}