
output "csr_ip" {
  value = aws_eip.csr.public_ip
}

output "tunnel_ip" {
  value = var.tunnel_ip
}

output "private_subnets" {
    value = module.vpc.private_subnets
}

output "consul_ip" {
  value = aws_instance.consul.private_ip
}

output "datacenter" {
  value = var.datacenter
}