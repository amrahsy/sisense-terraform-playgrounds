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

# Cluster
variable "cluster_version" {
  type        = string
  description = "Default version of Kubernetes EKS cluster"
  default     = "1.21"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = [] # ["audit", "api", "authenticator"]
}


# CloudWatch Log Group
variable "create_cloudwatch_log_group" {
  type        = bool
  default     = false
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
}

################################################################################
# EKS Managed Node Groups
################################################################################
variable "app_query_config" {
  type        = map(any)
  description = "Configuration of EKS Managed node group for Sisense App Query Nodes"
  default = {
    instance_type = "m5a.2xlarge"
    min_size      = 0
    max_size      = 3
    desired_size  = 1
  }
}

variable "bld_config" {
  type        = map(any)
  description = "Configuration of EKS Managed node group for Sisense Build Nodes"
  default = {
    instance_type = "m5a.2xlarge"
    min_size      = 0
    max_size      = 3
    desired_size  = 1
  }
}