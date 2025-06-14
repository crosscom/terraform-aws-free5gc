variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "free5gc-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.100.0.0/24", "10.100.1.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks for Kubernetes"
  type        = list(string)
  default     = ["10.100.2.0/24", "10.100.3.0/24"]
}

variable "multus_subnets_az1" {
  description = "Multus subnet CIDR blocks for AZ1"
  type        = map(string)
  default     = {
    "n2" = "10.100.50.0/24",
    "n3" = "10.100.51.0/24",
    "n4" = "10.100.52.0/24",
    "n6" = "10.100.100.0/24"
  }
}

variable "multus_subnets_az2" {
  description = "Multus subnet CIDR blocks for AZ2"
  type        = map(string)
  default     = {
    "n2" = "10.100.54.0/24",
    "n3" = "10.100.55.0/24",
    "n4" = "10.100.56.0/24",
    "n6" = "10.100.101.0/24"
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "free5gc-eks"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the cluster API endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the cluster API endpoint"
  type        = bool
  default     = true
}

variable "node_groups" {
  description = "Map of EKS managed node group definitions"
  type        = any
  default     = {
    free5gc_control_plane = {
      name           = "free5gc-control-plane"
      instance_types = ["m6i.4xlarge"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20
      min_size       = 1
      desired_size   = 1
      max_size       = 3
      subnet_key     = "private"
      az             = "az1"
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
      az             = "az1"
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
      az             = "az1"
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
      az             = "az1"
      labels = {
        "cnf" = "free5gc-upf2-az1"
      }
      kubelet_extra_args = "--cpu-manager-policy=static"
    }
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "free5gc"
    Terraform   = "true"
  }
}