resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_pip.id
  subnet_id = aws_subnet.nat_a.id

  tags = {
    Name = "natgw"
  }
}