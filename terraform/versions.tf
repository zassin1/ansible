terraform {
  required_version = ">= 1.6.0"

  backend "azurerm" {
    resource_group_name  = "rg-ansible-terraform-state"
    storage_account_name = "tfstatezassin1ansible"
    container_name       = "tfstate"
    key                  = "ansible-blog-dev.tfstate"
    use_oidc             = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
