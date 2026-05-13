variable "efs_sg_id" {
  type        = string
  description = "EFS security group id"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet ids"
}

variable "prefix" {
  type        = string
  description = "Prefix for naming resources"  
}