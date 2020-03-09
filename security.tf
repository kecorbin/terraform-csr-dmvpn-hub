
resource "aws_security_group" "csr_public" {
  name        = "csr-public"
  description = "Traffic Allowed from dirty internet"
  vpc_id      = aws_vpc.default.id

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
  vpc_id      = aws_vpc.default.id

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
  vpc_id      = aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_local" {
  security_group_id        = aws_security_group.allow_local.id
  source_security_group_id = aws_security_group.allow_local.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"

}

resource "aws_security_group" "private_subnet" {
  name        = "private_subnet"
  description = "Traffic Allowed from local VPC"
  vpc_id      = aws_vpc.default.id
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
