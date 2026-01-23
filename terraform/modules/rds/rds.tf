
resource "aws_db_subnet_group" "rds_subnet_grp" {
  name       = "main_subnet_grp"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "RDS subnet group"
  }
}

#Disabling for demo project 
#tfsec:ignore:aws-rds-enable-deletion-protection 
#tfsec:ignore:aws-rds-enable-iam-auth 
#tfsec:ignore:aws-rds-specify-backup-retention
#tfsec:ignore:aws-rds-encrypt-instance-storage-data
#tfsec:ignore:aws-rds-enable-performance-insights-encryption
resource "aws_db_instance" "db_instance" {
  allocated_storage            = 10
  db_name                      = "wordpressdb"
  identifier                   = "wordpress-db-instance"
  engine                       = "mysql"
  engine_version               = "8.0"
  instance_class               = "db.t3.micro"
  db_subnet_group_name         = aws_db_subnet_group.rds_subnet_grp.name
  vpc_security_group_ids       = [var.rds_sg_id]
  username                     = "wpadmin"
  manage_master_user_password  = true
  parameter_group_name         = "default.mysql8.0"
  skip_final_snapshot          = true
  performance_insights_enabled = false
}
