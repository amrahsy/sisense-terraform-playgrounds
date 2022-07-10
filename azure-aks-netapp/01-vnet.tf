################################################################################
# Provider: azurerm Provider Configuration
################################################################################
provider "azurerm" {
  features {}
}

################################################################################
# Resources: azurerm_resource_group
################################################################################
resource "random_pet" "prefix" {
  length = 1
}

resource "random_id" "suffix" {
  byte_length = 1
}

resource "azurerm_resource_group" "rg" {
  name     = local.environment_name
  location = var.region
}