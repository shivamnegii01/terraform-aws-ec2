# AWS Key Pair
resource "aws_key_pair" "mykey" {
  key_name   = "terra-key-ec2"
  public_key = file("terra-key-ec2.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = "automate-sg"
  description = "Terraform generated security group"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "automate-sg"
  }
}

# EC2 Instance
resource "aws_instance" "my_instance" {
  ami             = "ami-01a00762f46d584a1"
  instance_type   = "t3.micro"
  key_name        = aws_key_pair.mykey.key_name
  security_groups = [aws_security_group.my_security_group.name]

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "instance"
  }
}
