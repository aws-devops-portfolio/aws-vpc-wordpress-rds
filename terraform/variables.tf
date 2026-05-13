variable "vpc_cidr" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "app_prefix" {
  type        = string
  description = "Prefix for naming resources"
  default     = "wp-app"
}
