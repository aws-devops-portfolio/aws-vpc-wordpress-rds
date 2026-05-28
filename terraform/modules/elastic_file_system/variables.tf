variable "efs_sg_id" {
  type        = string
  description = "EFS security group id"
}

variable "efs_subnet_map" {
  type        = map(string)
  description = "Map of EFS subnet ids"
}

variable "prefix" {
  type        = string
  description = "Prefix for naming resources"  
}