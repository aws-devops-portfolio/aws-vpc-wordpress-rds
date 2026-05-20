output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private-subnet[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnet[*].id
}

output "efs_subnet_ids" {
  value = local.efs_subnet_ids
}