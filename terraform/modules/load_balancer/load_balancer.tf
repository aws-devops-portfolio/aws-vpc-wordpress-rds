
# Public ALB is required for Wordpress frontend access
#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "web_alb" {
  name                       = "wordpress-alb"
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "web_lb_tg" {
  name     = "wordpress-tg"
  port     = var.tg_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.interval
    timeout             = var.timeout 
    matcher             = 200-399        
  }
}

#tfsec:ignore:aws-elb-http-not-used
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = var.tg_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_lb_tg.arn
  }
}
