# Cravita Project 2 - Blue Green Deployment Infrastructure using Terraform & jenkins
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# module for vpc
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name

}

# module for sg
module "sg" {
  source = "./modules/sg"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# module for ec2_instance
module "ec2_instance" {
  source = "./modules/ec2_instance"

  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  blue_ec2_sg_id  = module.sg.blue_ec2_tg_sg_id
  green_ec2_sg_id = module.sg.green_ec2_tg_sg_id


  public_subnet_1_id  = module.vpc.public_subnet_1_id
  public_subnet_2_id  = module.vpc.public_subnet_2_id
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
  private_subnet_3_id = module.vpc.private_subnet_3_id
  private_subnet_4_id = module.vpc.private_subnet_4_id

}

# module for asg_alb_tg
module "asg_alb_tg" {
  source = "./modules/asg_alb_tg"

  #project_name = var.project_name
}