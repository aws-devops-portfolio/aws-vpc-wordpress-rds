resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow web access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb_sg"
  }
}

# Public ALB is required for Wordpress frontend access for demo project
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group_rule" "alb_sg_http_rule" {
  description       = "Load Balancer security group HTTP ingress rule"
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = [var.all_traffic]
  from_port         = var.http_port
  protocol          = "tcp"
  to_port           = var.http_port
}

# Public ALB is required for Wordpress frontend access for demo project
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group_rule" "alb_sg_https_rule" {
  description       = "Load Balancer security group HTTPS ingress rule"
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = [var.all_traffic]
  from_port         = var.https_port
  protocol          = "tcp"
  to_port           = var.https_port
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allows ALB to access the EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ec2_sg"
  }
}

#resource "aws_security_group_rule" "ec2_sg_ssh_rule" {
#  description       = "EC2 instance security group SSH ingress rule"
#  type              = "ingress"
#  security_group_id = aws_security_group.ec2_sg.id
#  cidr_blocks       = [var.all_traffic]
#  from_port         = var.ssh_port
#  protocol          = "tcp"
#  to_port           = var.ssh_port
#}

resource "aws_security_group_rule" "ec2_sg_http_rule" {
  description              = "EC2 instance security group HTTP ingress rule"
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  from_port                = var.http_port
  protocol                 = "tcp"
  to_port                  = var.http_port
}

resource "aws_security_group_rule" "ec2_sg_https_rule" {
  description              = "EC2 instance security group HTTPS ingress rule"
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  from_port                = var.https_port
  protocol                 = "tcp"
  to_port                  = var.https_port
}

# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "ec2_https_egress" {
  description       = "Allow EC2 outbound HTTPS (via NAT)"
  type              = "egress"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = [var.all_traffic]
  from_port         = var.https_port
  protocol          = "tcp"
  to_port           = var.https_port
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allows application to access the RDS instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "rds_sg"
  }
}

resource "aws_security_group_rule" "rds_sg_ingress_rule" {
  description              = "RDS security group ingress rule"
  type                     = "ingress"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
  from_port                = var.rds_port
  protocol                 = "tcp"
  to_port                  = var.rds_port
}