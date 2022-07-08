variable "aws-access-key" {
  description = "AWS Access Key"
  type        = string
  default     = ""
}

variable "aws-secret-key" {
  description = "AWS Secret Key"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "Default VPC ID"
  type        = string
  default     = "vpc-c7e377ae"
}

variable "subnet1" {
  description = "Subnet1 for Application Load Balancer"
  type        = string
  default     = "subnet-1ad75261"
}

variable "subnet2" {
  description = "Subnet2 for Application Load Balancer"
  type        = string
  default     = "subnet-eb1ed782"
}

variable "cert_arn" {
  description = "ARN for ACM certificate"
  type        = string
  default     = "arn:aws:acm:eu-west-2:401524530582:certificate/7718ee4c-713e-4ed5-89de-f271d0a45bb4"
}

variable "rt53_zone_id" {
  description = "Route 53 Zone ID"
  type        = string
  default     = "Z2EVGDY1W45NH9"
}

variable "rt_53_domain_name" {
  description = "Route 53 Domain Name"
  type        = string
  default     = "sentry.consultantconnect.org.uk"
}

variable "geoip_accountid" {
  description = "Maxmind Account/User ID"
  type        = string
  default     = "123456"
}

variable "geoip_license_key" {
  description = "Maxmind License key"
  type        = string
  default     = "abcdefghijk"
}

variable "admin_email" {
  description = "Sentry admin email"
  type        = string
  default     = "dev@consultantconnect.org.uk"
}

variable "url_prefix" {
  description = "Sentry URL prefix"
  type        = string
  default     = "https://sentry.consultantconnect.org.uk"
}

variable "sentry_version" {
  description = "Sentry self-hosted version"
  type        = string
  default     = "22.6.0"
}

variable "docker_compose_version" {
  description = "Docker compose version"
  type        = string
  default     = "2.6.1"
}

variable "google_client_id" {
  description = "Google OAuth2 client ID"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Google OAuth2 client secret"
  type        = string
  default     = ""
}

variable "github_app_id" {
  description = "GitHub app ID"
  type        = number
  default     = 12345
}

variable "github_api_secret" {
  description = "Github API secret"
  type        = string
  default     = ""
}

variable "github_app_name" {
  description = "Github app name"
  type        = string
  default     = "ConsultantConnect-Sentry"
}

variable "github_client_id" {
  description = "Github client ID"
  type        = string
  default     = ""
}

variable "github_private_key" {
  description = "Github private key"
  type        = string
  default     = ""
}

variable "github_webhook_secret" {
  description = "Github webhook secret"
  type        = string
  default     = ""
}

variable "restore_backups" {
  description = "Restore from backups after creating instance"
  type        = bool
  default     = true
}

variable "smtp_password" {
  description = "SMTP server password"
  type        = string
  default     = ""
}

variable "smtp_user" {
  description = "SMTP server user"
  type        = string
  default     = ""
}

variable "smtp_port" {
  description = "SMTP server port"
  type        = number
  default     = 587
}

variable "smtp_host" {
  description = "SMTP server hostname"
  type        = string
  default     = "email-smtp.eu-west-2.amazonaws.com"
}

variable "smtp_from" {
  description = "Sender name/address"
  type        = string
  default     = "Sentry <noreply@consultantconnect.org.uk>"
}

variable "smtp_namespace" {
  description = "mailing list namespace for emails sent by this Sentry server"
  type        = string
  default     = "consultantconnect.org.uk"
}
