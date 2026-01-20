data "aws_ssm_parameter" "wordpress_ami" {
  name = "/ami/wordpress/latest"
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source             = "./modules/rds"
  rds_sg_id          = module.sg.rds_sg_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "asg" {
  source               = "./modules/asg"
  wordpress_ami_id     = data.aws_ssm_parameter.wordpress_ami.value
  ec2_sg_id            = module.sg.ec2_sg_id
  instance_type        = var.instance_type
  private_subnet_ids   = module.vpc.private_subnet_ids
  db_secret_arn        = module.rds.db_master_secret_arn
  db_endpoint          = module.rds.db_endpoint
  alb_target_group_arn = module.alb.alb_target_group_arn
  key_pair_name        = "EC2PrivateKP2"

  depends_on = [module.rds]
}

module "alb" {
  source            = "./modules/alb"
  alb_sg_id         = module.sg.alb_sg_id
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}