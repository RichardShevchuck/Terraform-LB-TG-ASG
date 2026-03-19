output "web_load_balancer_url" {
  value = aws_lb.web.dns_name
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "aws_ami_id" {
  value = data.aws_ami.ubuntu.id
}
