data "aws_ssm_parameter" "wordpress_ami" {
  name = "/ami/wordpress/latest"
}

data "aws_route53_zone" "main" {
  name = "mike71techsolutions.com"
}

module "networks" {
  source       = "./modules/networks"
  vpc_cidr     = var.vpc_cidr  
  prefix       = var.app_prefix
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.networks.vpc_id
  prefix = var.app_prefix
}

module "elastic_file_system" {
  source         = "./modules/elastic_file_system"
  efs_sg_id      = module.security_groups.efs_sg_id
  efs_subnet_ids = module.networks.efs_subnet_ids
  prefix         = var.app_prefix
}


module "database" {
  source             = "./modules/database"
  rds_sg_id          = module.security_groups.rds_sg_id
  private_subnet_ids = module.networks.private_subnet_ids
  prefix             = var.app_prefix
}

module "load_balancer" {
  source            = "./modules/load_balancer"
  alb_sg_id         = module.security_groups.alb_sg_id
  vpc_id            = module.networks.vpc_id
  public_subnet_ids = module.networks.public_subnet_ids
  sub_domain        = "wordpress.mike71techsolutions.com"
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  prefix            = var.app_prefix
}

module "auto_scaling_group" {
  source               = "./modules/auto_scaling_group"
  ami_id               = data.aws_ssm_parameter.wordpress_ami.value
  ec2_sg_id            = module.security_groups.ec2_sg_id
  instance_type        = var.instance_type
  private_subnet_ids   = module.networks.private_subnet_ids
  db_secret_arn        = module.database.db_master_secret_arn
  db_endpoint          = module.database.db_endpoint
  alb_target_group_arn = module.load_balancer.alb_target_group_arn
  alb_dns              = module.load_balancer.alb_dns_name
  efs_id               = module.elastic_file_system.efs_id
  prefix               = var.app_prefix
  
  depends_on = [module.database]
}

# Sub domain record
resource "aws_route53_record" "sub_domain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "wordpress"
  type    = "A"

  alias {
    name                   = module.load_balancer.alb_dns_name
    zone_id                = module.load_balancer.alb_zone_id
    evaluate_target_health = true
  }
}