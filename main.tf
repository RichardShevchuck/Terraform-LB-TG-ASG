provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-*"]
  }

  owners = ["679593333241"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = [80, 443, 22]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "web_server"
    Owner   = "Richard"
    Project = "Terraform"
  }
}

resource "aws_key_pair" "aws" {
  key_name   = "web_server_key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_launch_template" "web_server_lt" {
  name_prefix            = "web_server_lt_"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  key_name               = aws_key_pair.aws.key_name

  user_data = base64encode(<<-EOF
#!/bin/bash
set -eux
apt-get update -y
apt-get install -y apache2
echo "Hello from Richard" > /var/www/html/index.html
systemctl enable apache2
systemctl restart apache2
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "web_server_instance"
      Owner   = "Richard"
      Project = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_default_subnet" "zone_1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "zone_2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_autoscaling_group" "web_server_asg" {
  name             = "web_server_asg"
  max_size         = 4
  min_size         = 2
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_default_subnet.zone_1.id,
    aws_default_subnet.zone_2.id
  ]

  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  dynamic "tag" {
    for_each = {
      Name    = "web_server_asg"
      Owner   = "Richard"
      Project = "Terraform"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_lb" "web" {
  name               = "web-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server_sg.id]
  subnets = [
    aws_default_subnet.zone_1.id,
    aws_default_subnet.zone_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name    = "web_lb"
    Owner   = "Richard"
    Project = "Terraform"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id


  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group" "web2" {
  name     = "web-tg2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id


  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}


