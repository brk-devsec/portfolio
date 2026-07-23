resource "aws_security_group" "brkim_sg" {
  name        = "brkim-sg"
  description = "ssh,http,mysql,icmp"
  vpc_id      = aws_vpc.brkim_vpc.id

  ingress = [
    {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = null
      self             = null
      prefix_list_ids  = null
    },
    {
      description      = "http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = null
      self             = null
      prefix_list_ids  = null
    },
    {
      description      = "mysql"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = null
      self             = null
      prefix_list_ids  = null
    },
    {
      description      = "icmp"
      from_port        = -1
      to_port          = -1
      protocol         = "icmp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = null
      self             = null
      prefix_list_ids  = null
    }
  ]
  egress = [
    {
      description      = "all"
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = null
      self             = null
      prefix_list_ids  = null
    }
  ]

  tags = {
    Name = "brkim-sg"
  }
}
