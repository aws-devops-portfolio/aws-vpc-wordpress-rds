output "alb_dns_name" {
  value = aws_lb.wp_alb.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.wp_alb_tg.arn
}

output "alb_zone_id" {
  value = aws_lb.wp_alb.zone_id
}