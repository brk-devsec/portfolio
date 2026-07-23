resource "aws_route_table" "igrt" {
  vpc_id = aws_vpc.brkim_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.brkim_ig.id
  }

  tags = {
    Name = "igrt"
  }
}
