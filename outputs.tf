output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "multus_subnet_ids_az1" {
  description = "Map of Multus subnet IDs in AZ1"
  value       = module.vpc.multus_subnet_ids_az1
}

output "multus_subnet_ids_az2" {
  description = "Map of Multus subnet IDs in AZ2"
  value       = module.vpc.multus_subnet_ids_az2
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.security.eks_cluster_sg_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = module.security.eks_node_sg_id
}

output "multus_security_group_id" {
  description = "Security group ID for Multus interfaces"
  value       = module.security.multus_sg_id
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = module.iam.eks_node_group_role_arn
}