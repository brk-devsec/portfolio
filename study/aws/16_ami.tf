resource "aws_ami_from_instance" "brkim_ami" {
  name = "brkim-ami"
  source_instance_id = aws_instance.brkim_weba.id
  depends_on = [aws_instance.brkim_weba]
}