# Elastic File System (EFS) 
resource "aws_efs_file_system" "wp_efs" {
  creation_token = "${var.prefix}-efs"
  encrypted      = true

  tags = {
    Name = "${var.prefix}-efs"
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "wp_efs_mount_target" {
  for_each = toset(var.efs_subnet_ids)

  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = each.value
  security_groups = [var.efs_sg_id] 
}