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
  availability_zone       = "us-east-1a"  
  map_public_ip_on_launch = true
  tags = {
    Name = "main-subnet"
  }
}

# Criando um Gateway de Internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Criando uma tabela de roteamento
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Associando a tabela de roteamento à sub-rede
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
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


# Criando a instância EC2
resource "aws_instance" "web" {
  ami           = "ami-0427090fd1714168b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids =  [aws_security_group.allow_ssh.id]

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