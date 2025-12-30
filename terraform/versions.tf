terraform {
  required_version = ">=1.9.0, <2.0.0"
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.12.0, < 5.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35.0, < 3.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0, < 3.0.0"
    }
  }
  backend "azurerm" {
  }
}


provider "azurerm" {
  features {
  }
  subscription_id = var.azrm_subscription_id
  tenant_id       = var.azrm_tenant_id
}

provider "random" {
}

provider "kubernetes" {
  host                   = module.aks_cluster.kube_admin_config[0].host
  username               = module.aks_cluster.kube_admin_config[0].username  
  password               = module.aks_cluster.kube_admin_config[0].password            
  client_certificate     = base64decode(module.aks_cluster.kube_admin_config[0].client_certificate)
  client_key             = base64decode(module.aks_cluster.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks_cluster.kube_admin_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks_cluster.kube_admin_config[0].host
    username               = module.aks_cluster.kube_admin_config[0].username
    password               = module.aks_cluster.kube_admin_config[0].password
    client_certificate     = base64decode(module.aks_cluster.kube_admin_config[0].client_certificate)
    client_key             = base64decode(module.aks_cluster.kube_admin_config[0].client_key)
    cluster_ca_certificate = base64decode(module.aks_cluster.kube_admin_config[0].cluster_ca_certificate)
  }
}