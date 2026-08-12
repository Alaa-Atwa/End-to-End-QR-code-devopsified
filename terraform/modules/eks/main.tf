resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    # Both subnet types passed in - the control plane needs to reach
    # nodes in private subnets, and can optionally expose a public endpoint
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_public_access   = true
    endpoint_private_access  = true
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = var.node_role_arn

  # Worker nodes go in private subnets only - matches the architecture
  # diagram from earlier, nodes aren't directly internet-reachable
  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 4
  }

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
}
