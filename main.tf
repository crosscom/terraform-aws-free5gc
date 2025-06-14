provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  multus_subnets_az1   = var.multus_subnets_az1
  multus_subnets_az2   = var.multus_subnets_az2
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = var.tags
}

module "security" {
  source = "./modules/security"

  vpc_id = module.vpc.vpc_id
  tags   = var.tags
}

module "iam" {
  source = "./modules/iam"

  tags = var.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  private_subnets                 = module.vpc.private_subnets
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_role_arn                = module.iam.eks_cluster_role_arn
  node_group_role_arn             = module.iam.eks_node_group_role_arn
  cluster_security_group_id       = module.security.eks_cluster_sg_id
  node_security_group_id          = module.security.eks_node_sg_id
  multus_security_group_id        = module.security.multus_sg_id
  multus_subnets_az1              = module.vpc.multus_subnet_ids_az1
  multus_subnets_az2              = module.vpc.multus_subnet_ids_az2
  
  # Node group configurations
  node_groups = var.node_groups

  tags = var.tags
}