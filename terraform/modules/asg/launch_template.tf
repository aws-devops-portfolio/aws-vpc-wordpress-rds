resource "aws_iam_role" "ec2_role" {
  name = "ec2-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "wordpress_lt" {
  name_prefix   = "wordpress-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_pair_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [var.ec2_sg_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = base64encode(
    templatefile("${path.module}/userdata.sh", {
      DB_SECRET_ARN  = var.db_secret_arn
      TF_DB_ENDPOINT = var.db_endpoint
      TF_DB_NAME     = var.db_name
    })
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "wordpress-asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "wordpress" {
  name                      = "wordpress-asg"
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.alb_target_group_arn]

  tag {
    key                 = "Name"
    value               = "wordpress-asg"
    propagate_at_launch = true
  }
}