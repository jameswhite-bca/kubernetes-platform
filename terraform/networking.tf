# Creating a virtual network with a unique name, telemetry settings, and in the specified resource group and location.
module "vnet" {
  source = "git::https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork.git?ref=v0.16.0"

  location         = var.azrm_resource_location
  parent_id        = module.resource_group.resource_id
  address_space    = ["10.0.0.0/16"]
  name             = module.naming.virtual_network.name

  subnets = {
    aks_subnet = {
      name             = join("-", ["aks", var.environment, "snet"])
      address_prefixes = ["10.0.1.0/24"]
    }
    }    
}