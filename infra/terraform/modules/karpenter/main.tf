# Karpenter FinOps Infrastructure Module (IAM, SQS Interruption Queue, NodeRole)
variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

# Karpenter Node IAM Role (Used by launched EC2 Spot & On-Demand instances)
resource "aws_iam_role" "karpenter_node" {
  name = "${var.cluster_name}-karpenter-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_WorkerNode" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_CNI" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ECR" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_node.name
}

# SQS Queue for Spot Interruption and Instance Rebalance Warnings
resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "${var.cluster_name}-karpenter-interruption"
  message_retention_seconds = 300
}

output "karpenter_node_role_arn" {
  value = aws_iam_role.karpenter_node.arn
}

output "interruption_queue_name" {
  value = aws_sqs_queue.karpenter_interruption.name
}
