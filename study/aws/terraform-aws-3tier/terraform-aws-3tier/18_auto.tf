resource "aws_autoscaling_group" "brkim_atsg" {
  name = "brkim-atsg"
  desired_capacity = 2
  min_size = 1
  max_size = 6
  health_check_grace_period = 30
  health_check_type = "EC2"
  force_delete = false
  vpc_zone_identifier = [aws_subnet.web_a.id,aws_subnet.web_c.id]
  launch_template {
    id = aws_launch_template.brkim_lantem.id
    version = "$Latest"
  }
  
}