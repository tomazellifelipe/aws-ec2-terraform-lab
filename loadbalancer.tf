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