resource "aws_launch_template" "brkim_lantem" {
  name = "brkim-lantem"
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }
  image_id = aws_ami_from_instance.brkim_ami.id
  instance_type = "t3.micro"
  key_name = "brkim-key"
  vpc_security_group_ids = [aws_security_group.brkim_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "brkim-temp"
    }
  }
}