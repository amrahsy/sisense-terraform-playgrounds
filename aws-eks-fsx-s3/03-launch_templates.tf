resource "aws_security_group" "allow_ssh_fsx_traffic" {
  name        = "${local.environment_name}-allow_ssh_fsx"
  description = "Allow SSH and FSX traffic for EKS Managed Node groups"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "FSX traffic from VPC"
    from_port   = 988
    to_port     = 988
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "app-qry-lt-one" {
  name_prefix            = "app-qry-lt-one-${local.environment_name}"
  description            = "EKS managed node group external launch template for Sisense App/Qry nodes"
  update_default_version = true

  instance_type = var.app_qry_config.instance_type
  key_name      = aws_key_pair.sisense_ssh_key_pair.key_name
  user_data     = filebase64("./scripts/sisense_s3_user_data")

  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id, aws_security_group.allow_ssh_fsx_traffic.id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-qry-node"
    }
  }
}

resource "aws_launch_template" "app-qry-lt-two" {
  name_prefix            = "app-qry-lt-two-${local.environment_name}"
  description            = "EKS managed node group external launch template for Sisense App/Qry nodes"
  update_default_version = true

  instance_type = var.app_qry_config.instance_type
  key_name      = aws_key_pair.sisense_ssh_key_pair.key_name
  user_data     = filebase64("./scripts/sisense_s3_user_data")

  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id, aws_security_group.allow_ssh_fsx_traffic.id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-qry-node"
    }
  }
}

resource "aws_launch_template" "bld-lt" {
  name_prefix            = "bld-lt-${local.environment_name}"
  description            = "EKS managed node group external launch template for Sisene Build Nodes"
  update_default_version = true

  instance_type = var.bld_config.instance_type
  key_name      = aws_key_pair.sisense_ssh_key_pair.key_name
  user_data     = filebase64("./scripts/sisense_s3_user_data")

  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id, aws_security_group.allow_ssh_fsx_traffic.id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "bld-node"
    }
  }
}