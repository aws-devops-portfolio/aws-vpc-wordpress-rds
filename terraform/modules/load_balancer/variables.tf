variable "alb_sg_id" {
  type        = string
  description = "Load Balancer security group id"
}
variable "vpc_id" {
  type        = string
  description = "VPC Id"
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet ids"
}
variable "http_port" {
  type        = number
  description = "Target group port"
  default     = 80
}
variable "https_port" {
  type        = number
  description = "HTTPS Target group port"
  default     = 443
}
variable "healthy_threshold" {
  type    = number
  default = 2
}
variable "unhealthy_threshold" {
  type    = number
  default = 2
}
variable "timeout" {
  type    = number
  default = 5
}
variable "interval" {
  type    = number
  default = 30
}
variable "sub_domain" {
  type        = string
  description = "Sub-domain from the hosted zone"
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Zone Id" 
}