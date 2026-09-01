####################################################
# Terraform Top Level Block Types
## Block-1: Terraform Settings Block
terraform {
    required_version = ">= 1.0.0"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">=2.0" # Optional but recommended in production"
        }
    }

    #Terraform State Storage to Azure Storage Account (Optional)  
    backend "azurerm" {
        resource_group_name  = "my-demo-rg1"
        storage_account_name = "mydemostorageaccount"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }  
}

#######################################################
# Block-2: Provider Block
provider "azurerm" {
    features {}
}
########################################################
# Block-3: Resource Block
#Create a Resource Group in Microsoft Azure
resource "azurerm_resource_group" "my_demo_rg1" {
    location = "eastus"
    name     = "my-demo-rg1"  
}

# Create Virtual Network in Microsoft Azure
resource "azurerm_virtual_network" "my_demo_vnet1" {
    name                = "my-demo-vnet1"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.my_demo_rg1.location
    resource_group_name = azurerm_resource_group.my_demo_rg1.name
}

########################################################
# Block-4: Input Variable Block
#Define Input Variable for Azure Region
variable "azure_region" {
    description = "Azure Region to deploy resources"
    type        = string
    default     = "eastus"
}
########################################################
# Block-5: Output Value Block
#Define Output Value for Resource Region
output "resource_group_location" {
    description = "Location of the Resource Group"
    value       = azurerm_resource_group.my_demo_rg1.location
}
########################################################
#Block-6: Local Values Block
locals {
    name= "${azurerm_resource_group.my_demo_rg1.name}-vnet"
}
########################################################
# Block-7: Data Sources Block
#Data Source to access information about an existing Azure Resource Group
data "azurerm_resource_group" "existing_rg" {
    name = "existing"
}
output "id" {
    value = data.azurerm_resource_group.existing_rg.id
}
########################################################
# Block-8: Modules Block
# Define a module to create a virtual machine in Azure
module "my_vm_module" {
    source              = "./modules/azure_vm"
    vm_name             = "my-demo-vm"
    resource_group_name = azurerm_resource_group.my_demo_rg1.name
    location            = azurerm_resource_group.my_demo_rg1.location
    vm_size             = "Standard_B1s"
}
# Azure Virtual Network Block using Terraform Modules (https://registry.terraform.io/modules/Azure/network/azurerm/latest)
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  address_spaces      = ["10.0.0.0/16", "10.2.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  depends_on = [azurerm_resource_group.example]
}
#####################################################################