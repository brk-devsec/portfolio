resource "aws_route_table_association" "natgwrt_weba" {
  route_table_id = aws_route_table.natgw_rt.id
  subnet_id      = aws_subnet.web_a.id
}

resource "aws_route_table_association" "natgwrt_webc" {
  route_table_id = aws_route_table.natgw_rt.id
  subnet_id      = aws_subnet.web_c.id
}
