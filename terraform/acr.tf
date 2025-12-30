module "container_registry" {
  source                   = "git::https://github.com/Azure/terraform-azurerm-avm-res-containerregistry-registry.git?ref=0.4.0"
  name                     = module.naming.container_registry.name
  location                 = var.azrm_resource_location
  resource_group_name      = module.resource_group.name
  admin_enabled            = true
  sku                      = "Basic"
  retention_policy_in_days = null #ACR retention policy can only be applied when using the Premium Sku.
  # need to override this default setting because zone redundancy isn't supported on Basic SKU.
  zone_redundancy_enabled = false
}