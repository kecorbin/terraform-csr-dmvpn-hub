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
  network_interface = aws_network_interface.g1.id
  vpc               = true
}

resource "aws_instance" "csr" {
  ami           = data.aws_ami.csr.id
  instance_type = var.csr_instance_size
  key_name      = var.ssh_keypair_name
  user_data     = data.template_file.csr_userdata.rendered
  
  network_interface {
    network_interface_id = aws_network_interface.g1.id
    device_index         = 0
  }  
  network_interface {
    network_interface_id = aws_network_interface.g2.id
    device_index         = 1
  }  

}

resource "aws_network_interface" "g1" {
  subnet_id         = aws_subnet.public_subnet.id
  security_groups   = [aws_security_group.csr_public.id]
  source_dest_check = false
}


resource "aws_network_interface" "g2" {
  subnet_id         = aws_subnet.private_subnet.id
  private_ips       = [var.csr_internal_ip]
  security_groups   = [aws_security_group.private_subnet.id]
  source_dest_check = false
}

