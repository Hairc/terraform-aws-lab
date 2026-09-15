output "eks_cluster_name" {
  description = "EKS Cluster name, needed to config kubectl"
  value       = aws_eks_cluster.my_cluster.name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API Server URL"
  value       = aws_eks_cluster.my_cluster.endpoint
}