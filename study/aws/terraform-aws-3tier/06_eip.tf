resource "aws_eip" "bat_pip" {
  domain = "vpc"

  tags = {
    Name = "bat-pip"
  }
}

resource "aws_eip" "natgw_pip" {
  domain = "vpc"

  tags = {
    Name = "natgw-pip"
  }
}

resource "aws_eip_association" "bat_eip" {
  instance_id = aws_instance.brkim_bat.id
  allocation_id = aws_eip.bat_pip.id
  depends_on = [ aws_instance.brkim_bat ]
}