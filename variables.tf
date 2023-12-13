variable "vpc_elevel_name_prefix" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_internet_gateway_id" {
  type = string
}

variable "public_cidr_block" {
  type = string
}

variable "exists_private_snet" {
  type = bool
}

variable "private_cidr_block" {
  type = string
  default = ""
}

variable "exists_isolated_snet" {
  type = bool
}

variable "isolated_cidr_block" {
  type = string
  default = ""
}
