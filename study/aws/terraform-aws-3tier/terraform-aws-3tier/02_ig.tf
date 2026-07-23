resource "aws_internet_gateway" "brkim_ig" {
  vpc_id = aws_vpc.brkim_vpc.id

  tags = {
    Name = "brkim-ig"
  }
}
