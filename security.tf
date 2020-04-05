
resource "aws_security_group" "csr_public" {
  name        = "csr-public"
  description = "Traffic Allowed from dirty internet"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // allow all traffic 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "allow_ssh" {
  name        = "ssh-public"
  description = "SSH Allowed from dirty internet"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // allow ssh 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "allow_local" {
  name        = "allow-local"
  description = "Traffic Allowed from local VPC"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16"]
  }
}

resource "aws_security_group" "private_subnet" {
  name        = "private_subnet"
  description = "Traffic Allowed from local VPC"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "private_subnet" {
  security_group_id        = aws_security_group.private_subnet.id
  source_security_group_id = aws_security_group.private_subnet.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"

}


resource "aws_security_group" "consul_servers" {
  name        = "consul servers"
  description = "traffic allowed to consul servers"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // allow ssh 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // allow internal traffic 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16"]
  }
  // allow consul ui 
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
