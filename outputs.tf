output "nat_gateway_ip" {
  description = "The Elastic IP address associated with the NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "egress_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "nat_gateway_id" {
  description = "The NAT Gateway ID"
  value       = module.vpc.nat_ids
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "cluster_name" {
  description = "The name of the cluster."
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks.cluster_version
}

output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.project_ingress.status
}

# output "load_balancer_ip" {
#   value = kubernetes_ingress_v1.project_ingress.status.0.load_balancer.0.ingress.0.ip
# }