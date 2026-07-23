resource "aws_db_subnet_group" "db_sg" {
  name       = "db-sg"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_c.id]
}

resource "aws_db_instance" "brkim_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  identifier             = "brkimmysql"
  username               = var.db_username
  password               = var.db_password
  availability_zone      = "ap-northeast-2a"
  db_subnet_group_name   = aws_db_subnet_group.db_sg.id
  vpc_security_group_ids = [aws_security_group.brkim_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "brkim-db"
  }
}
