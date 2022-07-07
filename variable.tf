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
