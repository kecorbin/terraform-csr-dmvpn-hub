variable "vpc_name" {
  default = "my-vpc"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "mgmt_cidr" {
}
variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "public_subnets" {
}

variable "private_subnets" {
}

variable "ssh_keypair_name" {}

variable "csr_instance_size" {
  default = "c4.large"
}
variable "csr_hostname" {}
variable "datacenter" {}
variable "csr_internal_ip" {
  default = "10.0.2.10"
}

variable "tunnel_key" {}

variable "nhrp_authentication_key" {}

variable "isakmp_key" {}

variable "tunnel_ip" {}