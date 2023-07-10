# AWS Provider
provider "aws" {
  region = var.aws_region
}

#The list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

#Define the VPC 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "week22_environment"
    Terraform   = "true"
  }
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name = each.key
    Tier = "private"
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name = each.key
    Tier = "private"
  }
}

#Route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id

  }
  tags = {
    Name      = "public_rtb"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "private_rtb"
    Terraform = "true"
  }
}

#Route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "week22_igw"
  }
}

#EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "week22_igw_eip"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "week22_nat_gateway"
  }
}

# EC2 Instances
resource "aws_instance" "web_server" {
  ami                    = var.ec2_ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets["public_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  #User Data in AWS EC2
  user_data = file("script.sh")

}

resource "aws_instance" "web_server2" {
  ami                    = var.ec2_ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets["public_subnet_2"].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  #User Data in AWS EC2
  user_data = file("script.sh")

}

# Security Group for EC2 Instance
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow all HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "rds_mysql" {
  engine                 = "mysql"
  engine_version         = var.rds_mysql_engine_version
  instance_class         = var.rds_mysql_instance_type
  allocated_storage      = var.rds_mysql_allocated_storage
  max_allocated_storage  = var.rds_mysql_max_allocated_storage
  storage_type           = "gp2"
  publicly_accessible    = false
  db_name                = var.rds_mysql_db_name
  username               = var.rds_mysql_username
  password               = var.rds_mysql_password
  db_subnet_group_name   = aws_db_subnet_group.sql_subnet_group.name
  port                   = "3306"
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  storage_encrypted      = true
  availability_zone      = var.rds_mysql_availability_zone
  skip_final_snapshot    = true

}

# RDS Subnet Group
resource "aws_db_subnet_group" "sql_subnet_group" {
  name       = "my-sql-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]
}

# Security Group for RDS MySQL Instance
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-security-group"
  description = "Security group for MySQL database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "db_instance_endpoint" {
  value = aws_db_instance.rds_mysql.endpoint
}