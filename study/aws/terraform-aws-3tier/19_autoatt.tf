resource "aws_autoscaling_attachment" "brkim_atsgatt" {
  autoscaling_group_name = aws_autoscaling_group.brkim_atsg.id
  lb_target_group_arn = aws_lb_target_group.brkim_lbtg.arn
}