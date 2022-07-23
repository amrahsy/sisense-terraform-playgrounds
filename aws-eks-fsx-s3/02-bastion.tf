################################################################################
# Data Sources: AWS AMI
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

################################################################################
# Resources: tls_private_key, aws_key_pair, aws_security_group
################################################################################

resource "tls_private_key" "bastion_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_ssh_key_pair" {
  key_name   = "bastion-${local.environment_name}"
  public_key = tls_private_key.bastion_private_key.public_key_openssh
  tags = {
    Name = "bastion-${local.environment_name}-key-pair"
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
    Name = "bastion-${local.environment_name}-sg"
  }
}

################################################################################
# Module: AWS EC2 Instance Module Configurations
################################################################################

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0.0"

  associate_public_ip_address = true
  ami                         = data.aws_ami.amazon_linux.id
  name                        = "bastion-${local.environment_name}"
  availability_zone           = module.vpc.azs[0]
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id] #module.eks.cluster_primary_security_group_id]
  key_name                    = aws_key_pair.bastion_ssh_key_pair.key_name

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = 20
      delete_on_termination = true
    }
  ]

  user_data_base64 = filebase64("./scripts/bastion_user_data")
}