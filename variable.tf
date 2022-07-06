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
  default     = ""
}

variable "subnet1" {
  description = "Subnet1 for Application Load Balancer"
  type        = string
  default     = ""
}

variable "subnet2" {
  description = "Subnet2 for Application Load Balancer"
  type        = string
  default     = ""
}

variable "cert_arn" {
  description = "ARN for ACM certificate"
  type        = string
  default     = ""
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
