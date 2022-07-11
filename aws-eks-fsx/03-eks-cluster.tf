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
  version = "~> 18.24.1"

  tags = {
    module = "eks"
  }
  # Cluster
  cluster_name                    = local.environment_name
  cluster_version                 = var.cluster_version
  cluster_enabled_log_types       = var.cluster_enabled_log_types
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_tags = {
    module = "eks"
  }

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
        module = "eks"
      }

      # Launch template
      create_launch_template = false
      launch_template_name   = ""

      # EKS Managed Node Group
      name           = "${local.environment_name}-qry-1"
      min_size       = "${var.app_query_config["min_size"]}"
      max_size       = "${var.app_query_config["max_size"]}"
      desired_size   = "${var.app_query_config["desired_size"]}"
      instance_types = ["${var.app_query_config["instance_type"]}"]
      disk_size      = 150
      labels = {
        node-sisense-Application = "true"
        node-sisense-Query       = "true"
      }
      remote_access = {
        ec2_ssh_key = aws_key_pair.bastion_ssh_key_pair.key_name
      }
    }

    # APP-QRY managed node group two
    app-qry-node-group-two = {
      tags = {
        module = "eks"
      }

      # Launch template
      create_launch_template = false
      launch_template_name   = ""

      # EKS Managed Node Group
      name           = "${local.environment_name}-qry-2"
      min_size       = "${var.app_query_config["min_size"]}"
      max_size       = "${var.app_query_config["max_size"]}"
      desired_size   = "${var.app_query_config["desired_size"]}"
      instance_types = ["${var.app_query_config["instance_type"]}"]
      disk_size      = 150
      labels = {
        node-sisense-Application = "true"
        node-sisense-Query       = "true"
      }
      remote_access = {
        ec2_ssh_key = aws_key_pair.bastion_ssh_key_pair.key_name
      }
    }

    # BLD managed node group
    bld-node-group = {
      tags = {
        module = "eks"
      }

      # Launch template
      create_launch_template = false
      launch_template_name   = ""

      # EKS Managed Node Group
      name           = "${local.environment_name}-bld"
      min_size       = "${var.bld_config["min_size"]}"
      max_size       = "${var.bld_config["max_size"]}"
      desired_size   = "${var.bld_config["desired_size"]}"
      instance_types = ["${var.bld_config["instance_type"]}"]
      disk_size      = 150
      labels = {
        node-sisense-Build = "true"
      }
      remote_access = {
        ec2_ssh_key = aws_key_pair.bastion_ssh_key_pair.key_name
      }
    }
  }
}