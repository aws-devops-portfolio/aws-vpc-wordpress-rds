variable "alb_sg_id" {
  type        = string
  description = "Load Balancer security group id"
}
variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet ids"
}
variable "tg_port" {
  type        = number
  description = "Target group port"
  default     = 80
}
variable "healthy_threshold" {
  type    = number
  default = 2
}
variable "unhealthy_threshold" {
  type    = number
  default = 10
}
variable "timeout" {
  type    = number
  default = 60
}
variable "interval" {
  type    = number
  default = 30
}