# ============================================================
# AWS Key Pair
# ============================================================
# Creates an AWS EC2 key pair that will be used to securely
# connect to the EC2 instance using SSH.
#
# The public key is read from the local file:
# terra-key-ec2.pub
#
# Make sure the corresponding private key is kept secure
# and is NOT uploaded to GitHub.
resource "aws_key_pair" "mykey" {
  key_name   = "terra-key-ec2"
  public_key = file("terra-key-ec2.pub")
}


# ============================================================
# Default VPC
# ============================================================
# Uses the default VPC available in the AWS account.
#
# The VPC ID is later used when creating the Security Group.
resource "aws_default_vpc" "default" {

}


# ============================================================
# Security Group
# ============================================================
# Creates a Security Group to control inbound and outbound
# network traffic for the EC2 instance.
#
# The Security Group is attached to the default VPC created
# or managed above.
resource "aws_security_group" "my_security_group" {
  name        = "automate-sg"
  description = "This will add a TF generated Security group"

  # Attach the Security Group to the default VPC.
  vpc_id = aws_default_vpc.default.id


  # ----------------------------------------------------------
  # Inbound Rules
  # ----------------------------------------------------------

  # Allow SSH connections on port 22.
  # This allows remote access to the EC2 instance.
  #
  # WARNING: 0.0.0.0/0 allows SSH from anywhere on the internet.
  # For production environments, restrict this to a trusted IP.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  # Allow HTTP traffic on port 80.
  # This allows users to access a web server running
  # on the EC2 instance.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }


  # ----------------------------------------------------------
  # Outbound Rules
  # ----------------------------------------------------------

  # Allow all outbound traffic from the EC2 instance.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All access open outbound"
  }


  # Tags help identify and organize AWS resources.
  tags = {
    name = "automate-sg"
  }
}


# ============================================================
# EC2 Instance
# ============================================================
# Creates an EC2 instance using the specified AMI and
# instance type.
#
# The instance is configured with:
# - SSH key pair for login
# - Security Group for network access
# - t3.micro instance type
# - 15 GB GP3 root volume
resource "aws_instance" "my_instance" {

  # Attach the previously created EC2 key pair.
  # This key is used for SSH authentication.
  key_name = aws_key_pair.mykey.key_name

  # Attach the Security Group created above.
  security_groups = [aws_security_group.my_security_group.name]

  # AWS EC2 instance type.
  # t3.micro is a small instance suitable for basic
  # development and learning workloads.
  instance_type = "t3.micro"

  # AMI used to create the EC2 instance.
  #
  # NOTE: AMI IDs are region-specific. Make sure this AMI
  # exists in the AWS region configured in your provider.
  ami = "ami-01a00762f46d584a1"


  # ----------------------------------------------------------
  # Root Block Device
  # ----------------------------------------------------------
  # Configure the root disk attached to the EC2 instance.
  root_block_device {
    # Root disk size in GB.
    volume_size = 15

    # Use AWS General Purpose SSD (gp3).
    volume_type = "gp3"
  }


  # ----------------------------------------------------------
  # EC2 Tags
  # ----------------------------------------------------------
  # Adds a name tag to make the EC2 instance easy to identify
  # in the AWS Management Console.
  tags = {
    name = "instance"
  }
}
