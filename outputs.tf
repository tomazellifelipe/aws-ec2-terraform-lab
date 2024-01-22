output "lb_dns" {
  description = "DNS do loadbalancer"
  value       = aws_lb.ec2_lb.dns_name
}