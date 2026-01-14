variable "rds_sg_id" {
  type = string
  description = "RDS security group id"
}
variable private_subnet_ids {
  type = list(string)
  description = "List of private subnet ids"  
}