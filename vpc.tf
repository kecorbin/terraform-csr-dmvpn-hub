data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.6"
  name                 = var.datacenter
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

}

resource "aws_route" "internal_10_nets" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "10.0.0.0/8"
  network_interface_id      = aws_network_interface.g2.id
}

resource "aws_route" "default_route" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "76.0.0.0/8"
  network_interface_id      = aws_network_interface.g2.id
}

resource "aws_route" "internal_192_168_nets" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = "192.168.0.0/16"
  network_interface_id      = aws_network_interface.g2.id
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}