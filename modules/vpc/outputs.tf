output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "multus_subnet_ids_az1" {
  description = "Map of Multus subnet IDs in AZ1"
  value       = { for k, v in aws_subnet.multus_az1 : k => v.id }
}

output "multus_subnet_ids_az2" {
  description = "Map of Multus subnet IDs in AZ2"
  value       = { for k, v in aws_subnet.multus_az2 : k => v.id }
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}