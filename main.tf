provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region     = var.region
}

resource "aws_iam_role" "sentry_iam_role" {
  name               = "sentry_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "sentry_instance_profile" {
  name  = "sentry_instance_profile"
  role = "sentry_iam_role"
}

resource "aws_iam_role_policy" "sentry_iam_role_policy" {
  name   = "sentry_iam_role_policy"
  role   = aws_iam_role.sentry_iam_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::cc-sentry-backups"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::cc-sentry-backups/*"]
    }
  ]
}
EOF
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
  ami             = "ami-078a289ddf4b09ae0"
  instance_type   = "t3a.xlarge"
  key_name        = aws_key_pair.Sentry_key.key_name
  security_groups = [aws_security_group.Sentry_EC2.name]
  iam_instance_profile = "${aws_iam_instance_profile.sentry_instance_profile.id}"
  user_data       = <<-EOF
#!/bin/bash
echo “Updating Packages”
sudo yum update -y
echo “Installing Docker”
sudo yum install docker -y
echo “Starting Docker”
sudo systemctl enable --now docker
echo “Adding ec2-user to Docker Group”
sudo usermod -aG docker ec2-user
docker pull loomchild/volume-backup
echo “Fetching Docker Compose”
sudo curl -L https://github.com/docker/compose/releases/download/v${var.docker_compose_version}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
echo “Modifying permission for Docker Compose”
sudo chmod +x /usr/local/bin/docker-compose
echo “Creating softlink for Docker Compose”
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
echo “Checking Docker Compose Version”
sudo docker-compose --version
mkdir -p /opt/sentry/current
mkdir -p /opt/sentry/backup
cd /opt/sentry/current
echo “Fetching Sentry Package”
sudo curl -LJO https://github.com/getsentry/onpremise/archive/${var.sentry_version}.tar.gz
sudo tar -zxvf self-hosted-${var.sentry_version}.tar.gz -C .
rm self-hosted-${var.sentry_version}.tar.gz
cd self-hosted-${var.sentry_version}
echo "applying sentry config"
cat << XXX >> sentry/config.example.yml
system.admin-email: "${var.admin_email}"
system.url-prefix: "${var.url_prefix}"
auth-google.client-id: "${var.google_client_id}"
auth-google.client-secret: "${var.google_client_secret}"
github-app.id: ${var.github_app_id}
github-app.name: "${var.github_app_name}"
github-app.client-id: "${var.github_client_id}"
github-app.client-secret: ${var.github_api_secret}
github-app.webhook-secret: "${var.github_client_id}"
github-app.private-key: |
  ${var.github_private_key}
github-login.client-id: "${var.github_client_id}"
github-login.require-verified-email: true
XXX
cat << YYY >> sentry/sentry.conf.example.py
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
YYY
cat << ZZZ >> .env
SENTRY_MAIL_HOST=email.eu-west-2.amazonaws.com
ZZZ
cat << AAA >> geoip/GeoIP.conf
AccountID ${var.geoip_accountid}
LicenseKey ${var.geoip_license_key}
EditionIDs GeoLite2-City
AAA
cat << BBB >> /opt/sentry/backup/backup.sh
#!/bin/bash
SENTRY_VOLUMES=("sentry-data" "sentry-postgres" "sentry-redis" "sentry-zookeeper" "sentry-kafka" "sentry-clickhouse" "sentry-symbolicator")
cd /opt/sentry/current/self-hosted-${var.sentry_version}
docker-compose down
for i in "\$${SENTRY_VOLUMES[@]}"
do
    docker run -v "\$${i}":/volume --rm --log-driver none loomchild/volume-backup backup - > /opt/sentry/backup/"\$${i}".tar.bz2
done
docker-compose up -d
aws s3 cp /opt/sentry/backup s3://cc-sentry-backups --recursive --exclude "*" --include "*.tar.bz2"
rm -rf *.tar.bz2
BBB
sudo chmod +x /opt/sentry/backup/backup.sh
cat << CCC >> /opt/sentry/backup/restore_backups.sh
#!/bin/bash
SENTRY_VOLUMES=("sentry-data" "sentry-postgres" "sentry-redis" "sentry-zookeeper" "sentry-kafka" "sentry-clickhouse" "sentry-symbolicator")
aws s3 cp s3://cc-sentry-backups /opt/sentry/backup --recursive --exclude "*" --include "*.tar.bz2"
cd /opt/sentry/current/self-hosted-${var.sentry_version}
docker-compose down
for i in "\$${SENTRY_VOLUMES[@]}"
do
    docker run -i -v "\$${i}":/volume --rm loomchild/volume-backup restore -f - < /opt/sentry/backup/"\$${i}".tar.bz2
done
rm -rf *.tar.bz2
docker-compose up -d
CCC
sudo chmod +x /opt/sentry/backup/restore_backups.sh
echo “Installing Sentry”
sudo ./install.sh --no-user-prompt
if ${var.restore_backups}
then
  echo "Restoring Backups"
  sudo /opt/sentry/backup/restore_backups.sh
else
  echo “Starting Sentry”
  sudo docker-compose up -d
fi
EOF
  tags = {
    Name = "SentryEC2Server"
  }
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
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = var.cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.Sentry-alb-https.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "Sentry-alb-http" {
  load_balancer_arn = aws_alb.Sentry-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "sentry_route53_record" {
  zone_id = var.rt53_zone_id
  name    = var.rt_53_domain_name
  type    = "A"

  alias {
    name                   = aws_alb.Sentry-alb.dns_name
    zone_id                = aws_alb.Sentry-alb.zone_id
    evaluate_target_health = true
  }
}
