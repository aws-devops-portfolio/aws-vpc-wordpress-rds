output "alb_url" {
  value = aws_lb.web_alb.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.web_lb_tg.arn 
}