provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "remote-backend-jreid" {
  bucket = "remote-backend-jreid"
  tags = {
    Name        = "remote_backend"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_remote-backend-jreid" {
  bucket = aws_s3_bucket.remote-backend-jreid.id
  versioning_configuration {
    status = "Enabled"
  }
}

# data "terraform_remote_state" "remote_state" {
#   backend = "s3"
#   config = {
#     bucket = aws_s3_bucket.remote-backend-jreid.bucket
#     key    = "terraform.tfstate"
#     region = "us-east-1"
#   }
# }

resource "aws_security_group" "week21_sg" {
  name        = "week21_sg"
  description = "Allow all incoming traffic"
  vpc_id      = "vpc-00821b9cce139e7b8"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = file("script.sh")
}

resource "aws_launch_template" "week21_lt" {
  name_prefix   = "week21_lt"
  image_id      = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.week21_sg.id]
  
  user_data = base64encode(data.template_file.user_data.rendered)
}

resource "aws_autoscaling_group" "week21_asg" {
  name                = "week21_asg"
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = ["subnet-07fc4bdcd8f8a72f2", "subnet-093f687adeb2196e3"]

  launch_template {
    id      = aws_launch_template.week21_lt.id
    version = aws_launch_template.week21_lt.latest_version
  }
}