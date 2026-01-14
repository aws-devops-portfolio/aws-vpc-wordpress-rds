variable "wordpress_ami_id" {
  type = string
  description = "Wordpress AMI id"
}

variable "ec2_sg_id" {
  type = string
  description = "EC2 instance security group id"
}
variable "instance_type" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
  description = "List of public subnet ids"
}
variable "db_secret_arn" {
  type = string
  description = "Database secrets ARN" 
}
variable "db_endpoint" {
  type = string
  description = "Database endpoint"
}
variable "db_name" {
  type = string
  description = "Database name"
  default = "wordpressdb"
}
variable "alb_target_group_arn" {
  type = string
  description = "Load Balancer target group ARN"    
}
variable "key_pair_name" {
  type = string 
  description = "EC2 instance key pair name"
}