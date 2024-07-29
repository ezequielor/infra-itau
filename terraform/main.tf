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

# Definindo o provedor AWS
provider "aws" {
  region = "us-east-1"
}

# Criando uma VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Criando uma sub-rede
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"  # Altere para a zona de disponibilidade desejada
  map_public_ip_on_launch = true
  tags = {
    Name = "main-subnet"
  }
}

# Criando um grupo de segurança
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}

# Criando uma chave SSH
resource "aws_key_pair" "deployer" {
  key_name   = "my-key"
  public_key = file("./ec2.pub")
}

# Criando a instância EC2
resource "aws_instance" "web" {
  ami           = "ami-0427090fd1714168b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  key_name       = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "my-instance"
  }
}

# Criando um Elastic IP (opcional)
resource "aws_eip" "ip" {
  instance = aws_instance.web.id
}

output "instance_ip" {
  value = aws_eip.ip.public_ip
}
