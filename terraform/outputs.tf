output "region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_id
}
