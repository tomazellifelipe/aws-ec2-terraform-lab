data "aws_ami" "amzlinux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.3.20240122.0-kernel-6.1-x86_64"]
  }
}
resource "aws_launch_template" "ec2_launch_template" {
  name_prefix   = "ec2-launch-template"
  image_id      = data.aws_ami.amzlinux.id
  instance_type = "t2.micro"
  user_data     = filebase64("user_data.sh")
  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.ec2_private_a.id
    security_groups             = [aws_security_group.ec2_sg.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "httpd-instance"
    }
  }
}
resource "aws_autoscaling_group" "ec2_asg" {
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  target_group_arns = [aws_lb_target_group.ec2_tg.arn]
  vpc_zone_identifier = [
    aws_subnet.ec2_private_a.id
  ]
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
}
resource "aws_security_group" "lb_sg" {
  name   = "lb-sg"
  vpc_id = aws_vpc.ec2_vpc.id
  # ingress {
  #   description      = "Allow http request from anywhere"
  #   protocol         = "tcp"
  #   from_port        = 80
  #   to_port          = 80
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }
  # ingress {
  #   description      = "Allow https request from anywhere"
  #   protocol         = "tcp"
  #   from_port        = 443
  #   to_port          = 443
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}
resource "aws_vpc_security_group_ingress_rule" "http_all_in" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "https_all_in" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.lb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.ec2_vpc.id
  ingress {
    description     = "Allow http request from Load Balancer"
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}