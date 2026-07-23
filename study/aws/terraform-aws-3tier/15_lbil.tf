resource "aws_lb_listener" "brkim_lbli" {
  load_balancer_arn = aws_lb.brkim_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.brkim_lbtg.arn
  }
}