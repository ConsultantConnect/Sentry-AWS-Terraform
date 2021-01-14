output "EC2InstancePublicIP" {
  value = aws_instance.SentryEC2Server.public_ip
}

output "SentryLoginURL" {
  value = aws_alb.Sentry-alb.dns_name
}
