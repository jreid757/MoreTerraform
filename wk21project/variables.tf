variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "remote-backend-jreid"
}

variable "bucket_tags" {
  description = "Tags for the S3 bucket"
  type        = map(string)
  default     = {
    Name        = "remote_backend"
    Environment = "Dev"
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = "vpc-00821b9cce139e7b8"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "week21_sg"
}

variable "ingress_ports" {
  description = "List of ingress ports"
  type        = list(number)
  default     = [80, 443, 22]
}

variable "ingress_cidr_blocks" {
  description = "List of ingress CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_ports" {
  description = "List of egress ports"
  type        = list(number)
  default     = [0]
}

variable "egress_cidr_blocks" {
  description = "List of egress CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "launch_template_name_prefix" {
  description = "Name prefix for the launch template"
  type        = string
  default     = "week21_lt"
}

variable "image_id" {
  description = "ID of the Amazon Machine Image (AMI)"
  type        = string
  default     = "ami-053b0d53c279acc90"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  type        = string
  default     = "week21_asg"
}

variable "min_size" {
  description = "Minimum number of instances in the autoscaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the autoscaling group"
  type        = number
  default     = 5
}

variable "desired_capacity" {
  description = "Desired number of instances in the autoscaling group"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of availability zones for the autoscaling group"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
