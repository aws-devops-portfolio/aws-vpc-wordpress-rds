data "aws_ssm_parameter" "wordpress_ami" {
  name = "/ami/wordpress/latest"
}

module "networks" {
  source   = "./modules/networks"
  vpc_cidr = var.vpc_cidr
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.networks.vpc_id
}

module "database" {
  source             = "./modules/database"
  rds_sg_id          = module.security_groups.rds_sg_id
  private_subnet_ids = module.networks.private_subnet_ids
}

module "load_balancer" {
  source            = "./modules/load_balancer"
  alb_sg_id         = module.security_groups.alb_sg_id
  vpc_id            = module.networks.vpc_id
  public_subnet_ids = module.networks.public_subnet_ids
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
  key_pair_name        = "EC2PrivateKP2"

  depends_on = [module.database]
}