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
# EC2 Outputs
################################################################################

output "ec2_nodes" {
  value = module.ec2-instance
}

output "sisense_private_key_openssh" {
  value     = tls_private_key.sisense_private_key.private_key_openssh
  sensitive = true
}

output "sisense_public_key_openssh" {
  value = tls_private_key.sisense_private_key.public_key_openssh
}