# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = "eks-cluster-sg"
    },
    var.tags
  )
}

# Allow all outbound traffic from the cluster
resource "aws_security_group_rule" "cluster_egress" {
  security_group_id = aws_security_group.eks_cluster.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# EKS Node Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = "eks-node-sg"
    },
    var.tags
  )
}

# Allow all outbound traffic from the nodes
resource "aws_security_group_rule" "nodes_egress" {
  security_group_id = aws_security_group.eks_nodes.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "nodes_internal" {
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  description              = "Allow nodes to communicate with each other"
}

# Allow worker nodes to communicate with the cluster API Server
resource "aws_security_group_rule" "nodes_to_cluster" {
  security_group_id        = aws_security_group.eks_cluster.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  description              = "Allow worker nodes to communicate with the cluster API Server"
}

# Allow cluster API Server to communicate with the worker nodes
resource "aws_security_group_rule" "cluster_to_nodes" {
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  description              = "Allow cluster API Server to communicate with the worker nodes"
}

# Allow SSH access to the nodes
resource "aws_security_group_rule" "nodes_ssh" {
  security_group_id = aws_security_group.eks_nodes.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH access to the nodes"
}

# Allow ICMP ping to the nodes
resource "aws_security_group_rule" "nodes_icmp" {
  security_group_id = aws_security_group.eks_nodes.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow ICMP ping to the nodes"
}

# Multus Security Group for secondary interfaces
resource "aws_security_group" "multus" {
  name        = "multus-sg"
  description = "Security group for Multus secondary interfaces"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = "multus-sg"
    },
    var.tags
  )
}

# Allow all traffic for Multus interfaces
resource "aws_security_group_rule" "multus_ingress" {
  security_group_id = aws_security_group.multus.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all inbound traffic for Multus interfaces"
}

resource "aws_security_group_rule" "multus_egress" {
  security_group_id = aws_security_group.multus.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic for Multus interfaces"
}