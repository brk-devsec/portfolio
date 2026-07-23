resource "aws_lb" "brkim_lb" {
  name = "brkim-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.brkim_sg.id]
  subnets = [aws_subnet.load_a.id, aws_subnet.load_c.id]
  
  tags = {
    Name = "brkim-lb"
  }
  }
  