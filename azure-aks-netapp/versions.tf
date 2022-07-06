# Edit cloud block as per details of your Terraform Cloud account
terraform {
  cloud {
    organization = "SisensePlayground"

    workspaces {
      name = "azure-aks-netapp"
    }
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.12.0"
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
