################################################################################
# Global Values
################################################################################
variable "region" {
  type        = string
  description = "AWS Region Name"
}

variable "vpc_cidr" {
  type        = string
  description = "Default CIDR for the VPC"
  default     = "10.0.0.0/16"
}

################################################################################
# Locals
################################################################################

locals {
  environment_name          = "${random_pet.prefix.id}-${random_id.suffix.id}"
  sliced_availability_zones = length("${data.aws_availability_zones.available.names}") >= 4 ? slice("${data.aws_availability_zones.available.names}", 0, 3) : "${data.aws_availability_zones.available.names}"
}

################################################################################
# Bastion
################################################################################
variable "bastion_instance_type" {
  type        = string
  description = "Configuration of Bastion machine"
  default     = "t2.micro"
}

################################################################################
# FSX Shared Storage
################################################################################
variable "fsx_config" {
  type        = map(any)
  description = "Configuration of FSX Shared Storage"
  default = {
    deployment_type             = "PERSISTENT_1"
    storage_capacity            = 1200
    per_unit_storage_throughput = 200
  }
}

################################################################################
# EKS Cluster
################################################################################

variable "cluster_version" {
  type        = string
  description = "Default version of Kubernetes EKS cluster"
  default     = "1.22"
}

################################################################################
# EKS Managed Node Groups
################################################################################

variable "app_qry_config" {
  type        = map(any)
  description = "Configuration of EKS Managed node group for Sisense App Query Nodes"
  default = {
    instance_type = "r5d.2xlarge"
    min_size      = 0
    max_size      = 3
    desired_size  = 1
  }
}

variable "bld_config" {
  type        = map(any)
  description = "Configuration of EKS Managed node group for Sisense Build Nodes"
  default = {
    instance_type = "r5d.2xlarge"
    min_size      = 0
    max_size      = 3
    desired_size  = 1
  }
}

variable "s3_full_access_arn" {
  type = string
  description = "ARN for S3 Full Access Policy"
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
}