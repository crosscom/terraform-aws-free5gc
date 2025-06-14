output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.free5gc.vpc_id
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.free5gc.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.free5gc.cluster_endpoint
}

output "multus_subnet_ids_az1" {
  description = "Map of Multus subnet IDs in AZ1"
  value       = module.free5gc.multus_subnet_ids_az1
}

output "multus_subnet_ids_az2" {
  description = "Map of Multus subnet IDs in AZ2"
  value       = module.free5gc.multus_subnet_ids_az2
}