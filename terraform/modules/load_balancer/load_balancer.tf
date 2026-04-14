
# Public ALB is required for Wordpress frontend access
#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "web_alb" {
  name                       = "wordpress-alb"
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "web_alb_tg" {
  name     = "wordpress-tg"
  port     = var.http_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.interval
    timeout             = var.timeout 
    matcher             = "200-399"        
  }
}

# ACM Certificate
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = var.sub_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate Validation record
resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options :
    dvo.domain_name => dvo
  }

  zone_id = var.route53_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

# Certificate validation
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

# Listeners
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = var.http_port
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    
    redirect {
      port        = var.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_alb_tg.arn
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
}
