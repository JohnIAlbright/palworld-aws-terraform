variable "aws_region" {
  description = "AWS region for the Palworld infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "backup_bucket_name" {
  description = "S3 bucket used for Palworld server backups"
  type        = string
}

variable "home_ip" {
  description = "Public IP allowed to SSH into the Palworld server"
  type        = string
}
variable "alert_email" {
  description = "Email address used for Palworld monitoring alerts"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID used by the Palworld server"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID used by the Palworld EC2 instance"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name used for SSH access"
  type        = string
}