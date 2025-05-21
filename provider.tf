terraform {
  required_version = ">= 1.8.3"

  backend "azurerm" {}
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id            = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab" 
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  alias                      = "postgres_network"
  subscription_id            = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab" # DTS-SHARESERVICES-SBOX
}