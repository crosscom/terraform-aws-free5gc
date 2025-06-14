variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
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

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "node_group_role_arn" {
  description = "ARN of the IAM role for the EKS node groups"
  type        = string
}

variable "cluster_security_group_id" {
  description = "ID of the security group for the EKS cluster"
  type        = string
}

variable "node_security_group_id" {
  description = "ID of the security group for the EKS nodes"
  type        = string
}

variable "multus_security_group_id" {
  description = "ID of the security group for Multus interfaces"
  type        = string
}

variable "multus_subnets_az1" {
  description = "Map of Multus subnet IDs in AZ1"
  type        = map(string)
}

variable "multus_subnets_az2" {
  description = "Map of Multus subnet IDs in AZ2"
  type        = map(string)
}

variable "node_groups" {
  description = "Map of EKS managed node group definitions"
  type        = any
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["a", "b"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}