variable "all_traffic" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = 443
}

variable "rds_port" {
  type    = number
  default = 3306
}

variable "vpc_id" {
  type = string
}