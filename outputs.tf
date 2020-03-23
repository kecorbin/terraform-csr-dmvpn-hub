
output "csr_ip" {
  value = aws_eip.csr.public_ip
}

output "tunnel_ip" {
  value = var.tunnel_ip
}

output "public_subnet" {
    value = aws_subnet.public_subnet.id
}

output "private_subnet" {
    value = aws_subnet.public_subnet.id
}