##############################################################
#######                    Modules                     #######
##############################################################

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
  prefix  = [var.app_name, var.environment]
}

module "resource_group" {
  source   = "git::https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup.git?ref=0.2.1"
  location = var.azrm_resource_location
  name     = module.naming.resource_group.name
}