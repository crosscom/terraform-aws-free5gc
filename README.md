# AWS Free5GC Terraform Module

This Terraform module deploys the infrastructure required for running Free5GC on AWS EKS with Multus networking support.

## Features

- VPC with multi-AZ design
- EKS Cluster with managed node groups
- Multus networking support with dedicated subnets
- AWS-managed add-ons (vpc-cni, kube-proxy, CloudWatch Observability)
- Custom IAM roles and security configurations
- Launch templates with user-data for Multus ENI configuration

## Architecture

The module creates the following components:

- **VPC**: A VPC with public and private subnets across two availability zones
- **Networking**: Internet Gateway, NAT Gateways, and route tables
- **Security**: Security groups for EKS cluster, nodes, and Multus interfaces
- **IAM**: Roles and policies for EKS cluster and node groups
- **EKS**: Kubernetes cluster with managed node groups
- **Multus**: Secondary network interfaces for 5G network simulation (N2, N3, N4, N6)

## Usage

```hcl
module "free5gc" {
  source = "github.com/crosscom/terraform-aws-free5gc"

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
    # Additional node groups for UERANSIM and UPFs
  }

  tags = {
    Environment = "dev"
    Project     = "free5gc"
    Terraform   = "true"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region | `string` | `"us-west-2"` | no |
| vpc_name | Name of the VPC | `string` | `"free5gc-vpc"` | no |
| vpc_cidr | CIDR block for the VPC | `string` | `"10.100.0.0/16"` | no |
| azs | Availability zones to use | `list(string)` | `["us-west-2a", "us-west-2b"]` | no |
| public_subnets | Public subnet CIDR blocks | `list(string)` | `["10.100.0.0/24", "10.100.1.0/24"]` | no |
| private_subnets | Private subnet CIDR blocks for Kubernetes | `list(string)` | `["10.100.2.0/24", "10.100.3.0/24"]` | no |
| multus_subnets_az1 | Multus subnet CIDR blocks for AZ1 | `map(string)` | See default in variables.tf | no |
| multus_subnets_az2 | Multus subnet CIDR blocks for AZ2 | `map(string)` | See default in variables.tf | no |
| enable_nat_gateway | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| single_nat_gateway | Use a single NAT Gateway for all private subnets | `bool` | `false` | no |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in the VPC | `bool` | `true` | no |
| cluster_name | Name of the EKS cluster | `string` | `"free5gc-eks"` | no |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | `"1.30"` | no |
| cluster_endpoint_public_access | Enable public access to the cluster API endpoint | `bool` | `true` | no |
| cluster_endpoint_private_access | Enable private access to the cluster API endpoint | `bool` | `true` | no |
| node_groups | Map of EKS managed node group definitions | `any` | See default in variables.tf | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| private_subnets | List of IDs of private subnets |
| public_subnets | List of IDs of public subnets |
| multus_subnet_ids_az1 | Map of Multus subnet IDs in AZ1 |
| multus_subnet_ids_az2 | Map of Multus subnet IDs in AZ2 |
| cluster_id | EKS cluster ID |
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| node_security_group_id | Security group ID attached to the EKS nodes |
| multus_security_group_id | Security group ID for Multus interfaces |
| eks_cluster_role_arn | ARN of the EKS cluster IAM role |
| eks_node_group_role_arn | ARN of the EKS node group IAM role |

## Post-Deployment Steps

After deploying the infrastructure, you'll need to:

1. Install Multus CNI on the EKS cluster
2. Deploy Free5GC components using Kubernetes manifests or Helm charts
3. Configure network attachments for the Multus interfaces

## License

This module is licensed under the MIT License - see the LICENSE file for details.