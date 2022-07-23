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

  cluster_name                    = local.environment_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cluster_security_group   = false
  create_node_security_group      = false

  tags = {
    Environment = "${local.environment_name}"
    Terraform   = true
  }

  eks_managed_node_groups = {
    # APP-QRY managed node group one
    app-qry-node-group-one = {
      name                  = "${local.environment_name}-qry-1"
      create_security_group = false
      labels = {
        node-sisense-Application = "true"
        node-sisense-Query       = "true"
      }

      # Launch template
      create_launch_template  = false
      launch_template_name    = aws_launch_template.app-qry-lt-one.name
      launch_template_version = aws_launch_template.app-qry-lt-one.default_version

      # Autoscaling group
      min_size     = "${var.app_qry_config["min_size"]}"
      max_size     = "${var.app_qry_config["max_size"]}"
      desired_size = "${var.app_qry_config["desired_size"]}"

      tags = {
        Environment = "${local.environment_name}"
        Terraform   = true
      }
    }

    app-qry-node-group-two = {
      name                  = "${local.environment_name}-qry-2"
      create_security_group = false
      labels = {
        node-sisense-Application = "true"
        node-sisense-Query       = "true"
      }

      # Launch template
      create_launch_template  = false
      launch_template_name    = aws_launch_template.app-qry-lt-two.name
      launch_template_version = aws_launch_template.app-qry-lt-two.default_version

      # Autoscaling group
      min_size     = "${var.app_qry_config["min_size"]}"
      max_size     = "${var.app_qry_config["max_size"]}"
      desired_size = "${var.app_qry_config["desired_size"]}"

      tags = {
        Environment = "${local.environment_name}"
        Terraform   = true
      }
    }

    build-node-group = {
      name                  = "${local.environment_name}-bld"
      create_security_group = false
      labels = {
        node-sisense-Build = "true"
      }

      # Launch template
      create_launch_template  = false
      launch_template_name    = aws_launch_template.bld-lt.name
      launch_template_version = aws_launch_template.bld-lt.default_version

      # Autoscaling group
      min_size     = "${var.bld_config["min_size"]}"
      max_size     = "${var.bld_config["max_size"]}"
      desired_size = "${var.bld_config["desired_size"]}"

      tags = {
        Environment = "${local.environment_name}"
        Terraform   = true
      }
    }
  }
}