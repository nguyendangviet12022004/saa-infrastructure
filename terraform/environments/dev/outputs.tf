output "kubernetes_instance_ids" {
  description = "Kubernetes EC2 instance IDs keyed by node name."
  value       = module.compute.instance_ids
}

output "kubernetes_private_ips" {
  description = "Kubernetes node private IPs keyed by node name."
  value       = module.compute.private_ips
}

output "kubernetes_public_ips" {
  description = "Kubernetes node public IPs keyed by node name."
  value       = module.compute.public_ips
}
