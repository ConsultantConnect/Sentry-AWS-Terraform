provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region     = var.region
}

resource "tls_private_key" "Sentry_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "Sentry_private_key_file" {
  content         = tls_private_key.Sentry_private_key.private_key_pem
  filename        = "Sentry_key.pem"
  file_permission = 0400
}
resource "aws_key_pair" "Sentry_key" {
  key_name   = "Sentry"
  public_key = tls_private_key.Sentry_private_key.public_key_openssh
}

resource "aws_security_group" "Sentry_ALB" {
  name        = "Sentry_ALB"
  description = "Allow https inbound traffic"
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Sentry_ALB"
  }
}

resource "aws_security_group" "Sentry_EC2" {
  name        = "Sentry_http"
  description = "Allow http inbound traffic"
  ingress {
    description     = "Custom TCP"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.Sentry_ALB.id]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Sentry_EC2"
  }
}

resource "aws_instance" "SentryEC2Server" {
  ami             = "ami-096fda3c22c1c990a"
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.Sentry_key.key_name
  security_groups = [aws_security_group.Sentry_EC2.name]
  user_data       = <<-EOF
#!/bin/bash
echo “Updating Packages”
sudo yum update -y
echo “Adding Docker CE Repo”
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo “Modifying Docker Repo”
sudo sed -i s/7/8/g /etc/yum.repos.d/docker-ce.repo
echo “Installing Docker”
sudo yum install docker-ce -y
echo “Starting Docker”
sudo systemctl enable --now docker
echo “Adding ec2-user to Docker Group”
sudo usermod -aG docker ec2-user
echo “Fetching Docker Compose”
sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
echo “Modifying permission for Docker Compose”
sudo chmod +x /usr/local/bin/docker-compose
echo “Creating softlink for Docker Compose”
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
echo “Checking Docker Compose Version”
sudo docker-compose --version
echo “Fetching Sentry Package”
sudo curl -LJO https://github.com/getsentry/onpremise/archive/20.12.1.tar.gz
sudo tar -zxvf onpremise-20.12.1.tar.gz 
cd onpremise-20.12.1
echo “Exporting Undocumented Variable”
export CI=1
echo “Installing Sentry”
sudo ./install.sh
sudo docker-compose up -d 
EOF
  tags = {
    Name = "SentryEC2Server"
  }
}
resource "aws_iam_server_certificate" "Sentry_ALB_Certificate" {
  name             = "Sentry_ALB_Certificate"
  certificate_body = file("public.pem")
  private_key      = file("private.pem")
}

resource "aws_alb" "Sentry-alb" {
  name                       = "Sentry-alb"
  internal                   = false
  security_groups            = [aws_security_group.Sentry_ALB.id]
  subnets                    = [var.subnet1, var.subnet2]
  enable_deletion_protection = false
}

resource "aws_alb_target_group" "Sentry-alb-https" {
  name     = "Sentry-alb-https"
  vpc_id   = var.vpc_id
  port     = "9000"
  protocol = "HTTP"
  health_check {
    path                = "/_health/"
    port                = "9000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 8
    matcher             = "200"
  }
}

resource "aws_alb_target_group_attachment" "SentryEC2Server" {
  target_group_arn = aws_alb_target_group.Sentry-alb-https.arn
  target_id        = aws_instance.SentryEC2Server.id
  port             = "9000"
}

resource "aws_alb_listener" "Sentry-alb-https" {
  load_balancer_arn = aws_alb.Sentry-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_iam_server_certificate.Sentry_ALB_Certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.Sentry-alb-https.arn
    type             = "forward"
  }
}
