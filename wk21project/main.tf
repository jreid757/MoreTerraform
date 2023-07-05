resource "aws_s3_bucket" "remote_backend" {
  bucket = var.bucket_name
  tags   = var.bucket_tags
}

resource "aws_s3_bucket_versioning" "versioning_remote_backend" {
  bucket = aws_s3_bucket.remote_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "terraform_remote_state" "remote_state" {
  backend = "s3"
  config = {
    bucket = aws_s3_bucket.remote_backend.bucket
    key    = "terraform.tfstate"
    region = var.region
  }
}

resource "aws_security_group" "week21_sg" {
  name        = var.security_group_name
  description = "Allow all incoming traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.ingress_ports[0]
    to_port     = var.ingress_ports[0]
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  ingress {
    from_port   = var.ingress_ports[1]
    to_port     = var.ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  ingress {
    from_port   = var.ingress_ports[2]
    to_port     = var.ingress_ports[2]
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = var.egress_ports[0]
    to_port     = var.egress_ports[0]
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_blocks
  }
}

resource "aws_launch_template" "week21_lt" {
  name_prefix             = var.launch_template_name_prefix
  image_id                = var.image_id
  instance_type           = var.instance_type
  vpc_security_group_ids  = [aws_security_group.week21_sg.id]
  user_data               = filebase64("script.sh")
}

resource "aws_autoscaling_group" "week21_asg" {
  name                 = var.autoscaling_group_name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  availability_zones   = var.availability_zones

  launch_template {
    id      = aws_launch_template.week21_lt.id
    version = aws_launch_template.week21_lt.latest_version
  }
}
