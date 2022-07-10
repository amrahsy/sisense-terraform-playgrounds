# Edit cloud block as per details of your Terraform Cloud account
terraform {
  cloud {
    organization = "<CHANGE-ME>"

    workspaces {
      name = "aws-ec2-rook_ceph"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
  }

  required_version = "~> 1.2.2"
}
