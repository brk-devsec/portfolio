resource "aws_route_table" "natgw_rt" {
  vpc_id = aws_vpc.brkim_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "natgw-rt"
  }
}