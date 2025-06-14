provider "aws" {
  region = var.region
}

module "free5gc" {
  source = "../../"

  # VPC Configuration
  vpc_name             = "free5gc-vpc"
  vpc_cidr             = "10.100.0.0/16"
  azs                  = ["us-west-2a", "us-west-2b"]
  public_subnets       = ["10.100.0.0/24", "10.100.1.0/24"]
  private_subnets      = ["10.100.2.0/24", "10.100.3.0/24"]
  multus_subnets_az1   = {
    "n2" = "10.100.50.0/24",
    "n3" = "10.100.51.0/24",
    "n4" = "10.100.52.0/24",
    "n6" = "10.100.100.0/24"
  }
  multus_subnets_az2   = {
    "n2" = "10.100.54.0/24",
    "n3" = "10.100.55.0/24",
    "n4" = "10.100.56.0/24",
    "n6" = "10.100.101.0/24"
  }
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # EKS Configuration
  cluster_name                    = "free5gc-eks"
  cluster_version                 = "1.30"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Node Group Configuration
  node_groups = {
    free5gc_control_plane = {
      name           = "free5gc-control-plane"
      instance_types = ["m6i.4xlarge"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20
      min_size       = 1
      desired_size   = 1
      max_size       = 3
      subnet_key     = "private"
      az             = "a"
      labels = {
        "cnf" = "free5gc-az1"
      }
      kubelet_extra_args = "--cpu-manager-policy=static"
    },
    ueransim = {
      name           = "ueransim"
      instance_types = ["m6i.4xlarge"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20
      min_size       = 1
      desired_size   = 1
      max_size       = 1
      subnet_key     = "private"
      az             = "a"
      labels = {
        "cnf" = "ueransim-az1"
      }
      kubelet_extra_args = "--cpu-manager-policy=static"
    },
    upf1 = {
      name           = "upf1"
      instance_types = ["m6i.4xlarge"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20
      min_size       = 1
      desired_size   = 1
      max_size       = 1
      subnet_key     = "private"
      az             = "a"
      labels = {
        "cnf" = "free5gc-upf1-az1"
      }
      kubelet_extra_args = "--cpu-manager-policy=static"
    },
    upf2 = {
      name           = "upf2"
      instance_types = ["m6i.4xlarge"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20
      min_size       = 1
      desired_size   = 1
      max_size       = 1
      subnet_key     = "private"
      az             = "a"
      labels = {
        "cnf" = "free5gc-upf2-az1"
      }
      kubelet_extra_args = "--cpu-manager-policy=static"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "free5gc"
    Terraform   = "true"
  }
}