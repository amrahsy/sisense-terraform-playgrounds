################################################################################
# AWS Infra
################################################################################

output "environment_name" {
  value = local.environment_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

################################################################################
# Bastion
################################################################################

output "bastion_public_dns" {
  value = module.ec2-instance.public_dns
}

output "bastion_public_ip" {
  value = module.ec2-instance.public_ip
}

output "bastion_private_key_openssh" {
  value     = tls_private_key.bastion_private_key.private_key_openssh
  sensitive = true
}

output "bastion_public_key_openssh" {
  value = tls_private_key.bastion_private_key.public_key_openssh
}

################################################################################
# EKS Cluster
################################################################################
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = module.eks.cluster_id
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

################################################################################
# FSX Shared Storage
################################################################################
output "fsx_dns_name" {
  description = "FSX Shared Storage DNS Name"
  value       = aws_fsx_lustre_file_system.fsx-shared-storage.dns_name
}

output "fsx_mount_name" {
  description = "FSX Shared Storage Mount Name"
  value       = aws_fsx_lustre_file_system.fsx-shared-storage.mount_name
}