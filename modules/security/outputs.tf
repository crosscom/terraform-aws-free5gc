output "eks_cluster_sg_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_sg_id" {
  description = "ID of the EKS node security group"
  value       = aws_security_group.eks_nodes.id
}

output "multus_sg_id" {
  description = "ID of the Multus security group"
  value       = aws_security_group.multus.id
}