resource "aws_route_table_association" "igrt_bat" {
  route_table_id = aws_route_table.igrt.id
  subnet_id      = aws_subnet.bat_a.id
}

resource "aws_route_table_association" "igrt_nat" {
  route_table_id = aws_route_table.igrt.id
  subnet_id      = aws_subnet.nat_a.id
}

resource "aws_route_table_association" "igrt_loada" {
  route_table_id = aws_route_table.igrt.id
  subnet_id      = aws_subnet.load_a.id
}

resource "aws_route_table_association" "igrt_loadc" {
  route_table_id = aws_route_table.igrt.id
  subnet_id      = aws_subnet.load_c.id
}