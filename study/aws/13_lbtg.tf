resource "aws_lb_target_group" "brkim_lbtg" {
  name = "brkim-lbtg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.brkim_vpc.id

  health_check {
    enabled = true
    healthy_threshold = 5
    unhealthy_threshold = 3
    interval = 10
    matcher = "200"
    path = "/index.html"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 2
  }
}