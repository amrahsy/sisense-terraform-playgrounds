################################################################################
# Data Sources: AWS AMI
################################################################################

data "aws_ami" "cluster_ami_id" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

################################################################################
# Module: EKS Module Configurations
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.26.6"

  tags = {
    terraform_environment_name = "${local.environment_name}"
  }
  # Cluster
  cluster_name                    = local.environment_name
  cluster_version                 = var.cluster_version
  cluster_enabled_log_types       = var.cluster_enabled_log_types
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # CloudWatch Log Group
  create_cloudwatch_log_group = var.create_cloudwatch_log_group

  # Cluster Security Group
  vpc_id = module.vpc.vpc_id
  cluster_security_group_additional_rules = {
    ingress_fsx_storage_tcp = {
      description = "To node on port 988"
      protocol    = "tcp"
      from_port   = 988
      to_port     = 988
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  # Node Security Group
  node_security_group_additional_rules = {
    ingress_fsx_storage_tcp = {
      description = "To node on port 988"
      protocol    = "tcp"
      from_port   = 988
      to_port     = 988
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    # APP-QRY managed node group one
    app-qry-node-group-one = {
      tags = {
        terraform_environment_name = "${local.environment_name}"
      }

      # Launch template
      create_launch_template  = false
      launch_template_name    = aws_launch_template.external.name
      launch_template_version = aws_launch_template.external.default_version

      # EKS Managed Node Group
      name         = "${local.environment_name}-qry-1"
      min_size     = "${var.app_query_config["min_size"]}"
      max_size     = "${var.app_query_config["max_size"]}"
      desired_size = "${var.app_query_config["desired_size"]}"
      disk_size    = 100
      labels = {
        node-sisense-Application = "true"
        node-sisense-Query       = "true"
      }
    }
  }
}