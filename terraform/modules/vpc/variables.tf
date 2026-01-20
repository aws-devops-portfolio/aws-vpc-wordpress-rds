variable "vpc_cidr" {
  type = string
}

variable "az_count" {
  type    = number
  default = 2
}

variable "private_subnet_count" {
  type    = number
  default = 4
}