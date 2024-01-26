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
resource "aws_lb" "ec2_lb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.ec2_public_a.id, aws_subnet.ec2_public_b.id]
}
resource "aws_lb_target_group" "ec2_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ec2_vpc.id
}
resource "aws_lb_listener" "ec2_front_end" {
  load_balancer_arn = aws_lb.ec2_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_tg.arn
  }
}