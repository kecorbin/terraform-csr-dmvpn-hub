data "aws_ami" "csr" {
  most_recent = true

  filter {
    name   = "name"
    values = ["cisco-CSR-.16.12.01a-*"]
  }

  owners = ["679593333241"] # Cisco Systems
}

data "template_file" "csr_userdata" {
  template = "${file("${path.module}/templates/headend.tpl")}"
  vars = {
    hostname                = var.csr_hostname
    nhrp_authentication_key = var.nhrp_authentication_key
    tunnel_key              = var.tunnel_key
    private_subnet          = split("/", var.private_subnet_cidr)[0]
    isakmp_key              = var.isakmp_key
    tunnel_ip               = var.tunnel_ip
  }
}

resource "aws_eip" "csr" {
  depends_on = [
    aws_instance.csr
  ]
  associate_with_private_ip = aws_instance.csr.private_ip
  vpc               = true
}

resource "aws_instance" "csr" {
  ami           = data.aws_ami.csr.id
  instance_type = var.csr_instance_size
  key_name      = var.ssh_keypair_name
  user_data     = data.template_file.csr_userdata.rendered
  vpc_security_group_ids = [
    aws_security_group.csr_public.id,
    aws_security_group.allow_local.id
  ]
  subnet_id                   = aws_subnet.public_subnet.id
  source_dest_check = false

}



resource "aws_network_interface" "g2" {
  subnet_id         = aws_subnet.private_subnet.id
  private_ips       = [var.csr_internal_ip]
  security_groups   = [aws_security_group.private_subnet.id]
  source_dest_check = false

  attachment {
    instance     = aws_instance.csr.id
    device_index = 1
  }
}


output "csr_ip" {
  value = aws_eip.csr.public_ip
}

output "tunnel_ip" {
  value = var.tunnel_ip
}