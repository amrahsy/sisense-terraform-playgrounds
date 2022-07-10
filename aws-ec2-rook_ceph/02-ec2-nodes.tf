################################################################################
# Data Sources: For Amazon Linux and CentOS Stream 8
################################################################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "centos_stream_8" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["CentOS*8*x86_64*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

################################################################################
# Resources: tls_private_key, aws_key_pair, aws_security_group (only bastion)
################################################################################

resource "tls_private_key" "sisense_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "sisense_ssh_key_pair" {
  key_name   = "sisense-${local.environment_name}"
  public_key = tls_private_key.sisense_private_key.public_key_openssh
  tags = {
    Name = "sisense-${local.environment_name}-key-pair"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sisense-${local.environment_name}-sg"
  }
}

################################################################################
# Locals: Configurations of bastion and Sisense nodes(app-qry, bld) 
################################################################################

locals {
  multiple_instances = {
    bastion = {
      name              = "bastion-${local.environment_name}"
      ami               = data.aws_ami.amazon_linux.id
      instance_type     = var.bastion_instance_type
      availability_zone = element(module.vpc.azs, 0)
      subnet_id         = element(module.vpc.public_subnets, 0)
      user_data_base64  = filebase64("./scripts/bastion_user_data")
      root_block_device = [
        {
          volume_type           = "gp2"
          volume_size           = 20
          delete_on_termination = true
        }
      ]
      vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
      associate_public_ip_address = true
    }
    app-qry-1 = {
      name              = "app-qry-1-${local.environment_name}"
      ami               = data.aws_ami.centos_stream_8.id
      instance_type     = var.sisense_node_instance_type
      availability_zone = element(module.vpc.azs, 0)
      subnet_id         = element(module.vpc.private_subnets, 0)
      user_data_base64  = filebase64("./scripts/sisense_node_user_data")
      root_block_device = [
        {
          volume_type           = "gp2"
          volume_size           = 250
          delete_on_termination = true
        }
      ]
    }
    app-qry-2 = {
      name              = "app-qry-2-${local.environment_name}"
      ami               = data.aws_ami.centos_stream_8.id
      instance_type     = var.sisense_node_instance_type
      availability_zone = element(module.vpc.azs, 1)
      subnet_id         = element(module.vpc.private_subnets, 1)
      user_data_base64  = filebase64("./scripts/sisense_node_user_data")
      root_block_device = [
        {
          volume_type           = "gp2"
          volume_size           = 250
          delete_on_termination = true
        }
      ]
    }
    bld = {
      name              = "bld-${local.environment_name}"
      ami               = data.aws_ami.centos_stream_8.id
      instance_type     = var.sisense_node_instance_type
      availability_zone = length(module.vpc.azs) >= 3 ? element(module.vpc.azs, 2) : element(module.vpc.azs, 0)
      subnet_id         = length(module.vpc.azs) >= 3 ? element(module.vpc.private_subnets, 2) : element(module.vpc.azs, 0)
      user_data_base64  = filebase64("./scripts/sisense_node_user_data")
      root_block_device = [
        {
          volume_type           = "gp2"
          volume_size           = 250
          delete_on_termination = true
        }
      ]
    }
  }
}

################################################################################
# Module: AWS EC2 Instance Module Configurations
################################################################################

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0.0"

  for_each = local.multiple_instances

  name              = each.value.name
  ami               = each.value.ami
  instance_type     = each.value.instance_type
  availability_zone = each.value.availability_zone
  subnet_id         = each.value.subnet_id
  user_data_base64  = each.value.user_data_base64
  root_block_device = lookup(each.value, "root_block_device", [])

  key_name                    = aws_key_pair.sisense_ssh_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = each.key == "bastion" ? true : false
}