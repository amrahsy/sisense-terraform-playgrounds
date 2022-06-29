################################################################################
# Resources: aws_security_group, aws_fsx_lustre_file_system
################################################################################

resource "aws_fsx_lustre_file_system" "fsx-shared-storage" {
  storage_capacity            = var.fsx_config.storage_capacity
  subnet_ids                  = [module.vpc.public_subnets[0]]
  security_group_ids          = [module.eks.cluster_security_group_id]
  deployment_type             = var.fsx_config.deployment_type
  per_unit_storage_throughput = var.fsx_config.per_unit_storage_throughput

  tags = {
    Name = "LUSTRE-${local.environment_name}"
  }
}