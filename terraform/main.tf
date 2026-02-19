module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.environment}-redemption-vpc"
  cidr = var.vpc_cidr
  azs  = ["${var.region}a", "${var.region}b", "${var.region}c"]

  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 3)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 101), cidrsubnet(var.vpc_cidr, 8, 102), cidrsubnet(var.vpc_cidr, 8, 103)]

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment == "prod" ? false : true # Prod needs HA NAT
  one_nat_gateway_per_az = var.environment == "prod" ? true : false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    critical_addons = {
      min_size     = 2
      max_size     = 5
      desired_size = 2
      instance_types = var.instance_types
    }
  }
  enable_irsa = true
}