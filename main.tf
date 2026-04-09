module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = "web"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Name = "web"
  }
}

resource "aws_instance" "webserver" {
  ami = "ami-0ec10929233384c7f"
  instance_type = "t3.micro"
  associate_public_ip_address = true
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [ aws_security_group.webserver.id ]
  user_data = <<-EOF
              #! /bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enabled apache2
              echo "<h1>Ejecutando apache2</h1>" | sudo tee /var/www/html/index.html
              EOF
  tags = {
    Name = "webserver"
  }
}

resource "aws_security_group" "webserver" {
  vpc_id = module.vpc.vpc_id
  name = "webserver"
  tags = {
    Name = "webserver"
  }
}

resource "aws_vpc_security_group_ingress_rule" "port_80" {
  security_group_id = aws_security_group.webserver.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "TCP"
  depends_on = [ aws_security_group.webserver ]
}

resource "aws_vpc_security_group_ingress_rule" "port_443" {
  security_group_id = aws_security_group.webserver.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  to_port = 443
  ip_protocol = "TCP"
  depends_on = [ aws_security_group.webserver ]
}

resource "aws_vpc_security_group_egress_rule" "allow_egress" {
  security_group_id = aws_security_group.webserver.id
  depends_on = [ aws_security_group.webserver ]
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}