data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_iam_role_policy" "consul" {
  name = "${var.datacenter}-consul-policy"
  role = aws_iam_role.consul.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "consul" {
  name = "${var.datacenter}-consul-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "consul" {
  name = "${var.datacenter}-instance-prof"
  role = aws_iam_role.consul.name
}

data "template_file" "init" {
  template = "${file("${path.module}/templates/consul.tpl")}"
  vars = {
    datacenter = var.datacenter
    primary_datacenter = var.datacenter
    csr_hostname       = "${var.datacenter}-csr1"
    csr_private_ip     = aws_network_interface.g2.private_ip

  }
}

resource "aws_instance" "consul" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "m5.large"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.consul_servers.id
  ]
  user_data              = data.template_file.init.rendered
  iam_instance_profile   = aws_iam_instance_profile.consul.name
  key_name               = var.ssh_keypair_name
  tags = {
    Name = "consul"
    Env  = var.datacenter
  }
}

