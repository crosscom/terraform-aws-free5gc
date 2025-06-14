# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnets
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
  }

  # Enable CloudWatch logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.eks_cluster
  ]
}

# CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  tags = var.tags
}

# EKS Node Groups
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value.name
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = [var.private_subnets[0]]

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = aws_launch_template.this[each.key].latest_version
  }

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  # Allow external changes to autoscaling group
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = merge(
    var.tags,
    {
      "Name" = each.value.name
    }
  )

  depends_on = [
    aws_launch_template.this
  ]
}

# Launch Templates for Node Groups
resource "aws_launch_template" "this" {
  for_each = var.node_groups

  name_prefix = "${each.value.name}-"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  instance_type = each.value.instance_types[0]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        "Name" = each.value.name
      },
      each.value.labels
    )
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tpl", {
    cluster_name         = var.cluster_name
    node_group_name      = each.value.name
    kubelet_extra_args   = each.value.kubelet_extra_args
    multus_sg_id         = var.multus_security_group_id
    multus_subnets       = each.value.az == "az1" ? var.multus_subnets_az1 : var.multus_subnets_az2
    region               = var.region
  }))

  tags = merge(
    var.tags,
    {
      "Name" = each.value.name
    }
  )
}

# EKS Add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"

  tags = var.tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"

  tags = var.tags
}

resource "aws_eks_addon" "cloudwatch" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "amazon-cloudwatch-observability"

  tags = var.tags
}