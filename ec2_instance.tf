# Security Group for EC2 Instance
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-security-group"
  description = "Allow HTTP access"
  vpc_id      = aws_vpc.amc-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-sg"
  }
}

# Key pair for SSH access
resource "aws_key_pair" "nginx_key" {
  key_name   = "nginx-key"
  public_key = file("~/.ssh/nginx_key.pub")    # Path to the public key
}


# EC2 Instance
resource "aws_instance" "nginx_instance" {
  ami           = "ami-08970251d20e940b0" # Amazon Linux 2 AMI; update for your region
  instance_type = "t2.micro"              # Instance type

  key_name           = aws_key_pair.nginx_key.key_name
  subnet_id          = aws_subnet.public_a.id # Launch in the first public subnet
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "nginx-instance"
  }

  # Install and start nginx
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF
}

# Outputs
output "vpc_id" {
  value = aws_vpc.amc-vpc.id
}
output "nginx_instance_public_ip" {
  value = aws_instance.nginx_instance.public_ip
  description = "Public IP address of the Nginx instance"
}