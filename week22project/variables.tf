variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "week22_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
}

variable "public_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
  }
}

variable "ec2_ami_id" {
  type    = string
  default = "ami-053b0d53c279acc90"
}

variable "rds_mysql_engine_version" {
  type    = string
  default = "8.0.32"
}

variable "rds_mysql_instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_mysql_allocated_storage" {
  type    = number
  default = 20
}

variable "rds_mysql_max_allocated_storage" {
  type    = number
  default = 40
}

variable "rds_mysql_db_name" {
  type    = string
  default = "week22sql"
}

variable "rds_mysql_username" {
  type    = string
  default = "admin"
}

variable "rds_mysql_password" {
  type    = string
  default = "password"
}

variable "rds_mysql_availability_zone" {
  type    = string
  default = "us-east-1b"
}
