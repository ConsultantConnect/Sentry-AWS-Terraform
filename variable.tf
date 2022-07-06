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
  default     = ""
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
