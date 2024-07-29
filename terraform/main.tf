provider "aws" {
  region = "us-east-1"  
}

resource "aws_instance" "application" {
  ami = "ami-0427090fd1714168b"
  instance_type = "t2.micro"

  tags = {
    "Name" = "Test Itau Application"
  }
}

output "public_ip" {
  value = aws_instance.application.public_ip
}