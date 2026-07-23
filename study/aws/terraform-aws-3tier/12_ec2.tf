resource "aws_instance" "brkim_bat" {
  ami                    = "ami-08c766d1a55d29288"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.brkim_key.key_name
  availability_zone      = "ap-northeast-2a"
  private_ip             = "10.0.0.11"
  subnet_id              = aws_subnet.bat_a.id
  vpc_security_group_ids = [aws_security_group.brkim_sg.id]

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y lynx mariadb105
  EOT

  tags = {
    Name = "brkim-bat"
  }
}

resource "aws_instance" "brkim_weba" {
  ami                    = "ami-08c766d1a55d29288"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.brkim_key.key_name
  availability_zone      = "ap-northeast-2a"
  private_ip             = "10.0.2.11"
  subnet_id              = aws_subnet.web_a.id
  vpc_security_group_ids = [aws_security_group.brkim_sg.id]

  user_data = templatefile("${path.module}/install.sh.tpl", {
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_endpoint = aws_db_instance.brkim_db.address
  })

  tags = {
    Name = "brkim-weba"
  }

  depends_on = [
    aws_route_table_association.natgwrt_weba,
    aws_db_instance.brkim_db
  ]
}
