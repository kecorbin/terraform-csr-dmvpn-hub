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
    consul_ip = aws_instance.consul.private_ip    
    nhrp_authentication_key = var.nhrp_authentication_key
    tunnel_key              = var.tunnel_key
    isakmp_key              = var.isakmp_key
    tunnel_ip               = var.tunnel_ip
    // derive an IOS route for vpc cidr
    // e.g 10.1.0.0 255.255.0.0
    internal_route = join(" ", [split("/", var.vpc_cidr)[0], cidrnetmask(var.vpc_cidr)])
    // vpc router
    vpc_router = cidrhost(var.private_subnets[0], 1)

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
  subnet_id         = module.vpc.public_subnets[0]
  security_groups   = [aws_security_group.csr_public.id]
  source_dest_check = false
}


resource "aws_network_interface" "g2" {
  subnet_id         = module.vpc.private_subnets[0]
  private_ips       = [var.csr_internal_ip]
  security_groups = [aws_security_group.allow_local.id]
  source_dest_check = false
}

