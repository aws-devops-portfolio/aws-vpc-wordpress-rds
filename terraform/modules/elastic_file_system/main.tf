resource "aws_efs_file_system" "wp_efs" {
  creation_token = "${var.prefix}-efs"

  tags = {
    Name = "${var.prefix}-efs"
  }
}

resource "aws_efs_mount_target" "wp_efs_mount_target" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_sg_id] 
}