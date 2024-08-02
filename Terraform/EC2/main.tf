provider "aws" {
  region = "us-east-1"  # Specify the AWS region
}

resource "aws_instance" "dev" {
  ami             = "ami-0427090fd1714168b"  # Amazon Linux 2 AMI ID (us-east-1)
  instance_type   = "t2.micro"
  key_name        = "bwayne"
  vpc_security_group_ids = ["sg-069c77ecefe2f827e"]
  subnet_id       = "subnet-04abf71f6177d66c0"
  associate_public_ip_address = true

  tags = {
    Name     = "Dev"
    Business = "business"
  }

  root_block_device {
    volume_size = 100  # Size in GB
    encrypted   = true  # Enable encryption
  }
}

resource "aws_instance" "prod" {
  ami             = "ami-0427090fd1714168b"  # Amazon Linux 2 AMI ID (us-east-1)
  instance_type   = "t2.micro"
  key_name        = "bwayne"
  vpc_security_group_ids = ["sg-069c77ecefe2f827e"]
  subnet_id       = "subnet-04abf71f6177d66c0"
  associate_public_ip_address = true

  tags = {
    Name     = "Prod"
    Business = "business"
  }

  root_block_device {
    volume_size = 100  # Size in GB
    encrypted   = true  # Enable encryption
  }
}

resource "aws_instance" "security" {
  ami             = "ami-0427090fd1714168b"  # Amazon Linux 2 AMI ID (us-east-1)
  instance_type   = "t2.micro"
  key_name        = "bwayne"
  vpc_security_group_ids = ["sg-069c77ecefe2f827e"]
  subnet_id       = "subnet-04abf71f6177d66c0"
  associate_public_ip_address = true

  tags = {
    Name     = "Security"
    Business = "business"
  }

  root_block_device {
    volume_size = 100  # Size in GB
    encrypted   = true  # Enable encryption
  }
}

output "instance_ids" {
  value = [aws_instance.dev.id, aws_instance.prod.id, aws_instance.security.id]
}

output "instance_public_ips" {
  value = [aws_instance.dev.public_ip, aws_instance.prod.public_ip, aws_instance.security.public_ip]
}
