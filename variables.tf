variable "vpc_name" {
  default = "my-vpc"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "region" {
  default = "us-east-1"
}
variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}
variable "ssh_keypair_name" {}

variable "csr_instance_size" {
    default ="c4.large"
}

variable "csr_hostname" {
    default = "hub_1"
}

variable "csr_internal_ip" {
    default = "10.0.2.10"
}

variable "tunnel_key" {}

variable "nhrp_authentication_key" {}

variable "isakmp_key" {}

variable "tunnel_ip" {}