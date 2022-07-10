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
# Sisense Node Instance type
################################################################################
variable "sisense_node_instance_type" {
  type        = string
  description = "Configuration of Bastion machine"
  default     = "m5a.2xlarge"
}