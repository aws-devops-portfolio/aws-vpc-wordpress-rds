output "db_endpoint" {
    value = aws_db_instance.db_instance.endpoint
}

output "db_master_secret_arn" {
  value = aws_db_instance.db_instance.master_user_secret[0].secret_arn
}