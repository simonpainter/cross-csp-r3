# Azure

provider "azurerm" {

  client_id       = var.client_id
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_secret   = var.client_secret


  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = true
    }
  }
}


# AWS

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


