# Create a user-assigned managed identity for AKS control plane
resource "azurerm_user_assigned_identity" "aks_control_plane" {
  location            = var.azrm_resource_location
  name                = "${module.naming.kubernetes_cluster.name}-control-plane"
  resource_group_name = module.resource_group.name
}

# Create a user-assigned managed identity for AKS kubelet
resource "azurerm_user_assigned_identity" "aks_kubelet" {
  location            = var.azrm_resource_location
  name                = "${module.naming.kubernetes_cluster.name}-kubelet"
  resource_group_name = module.resource_group.name
}

# Grant control plane identity "Managed Identity Operator" role on kubelet identity
resource "azurerm_role_assignment" "aks_control_plane_mio" {
  principal_id                     = azurerm_user_assigned_identity.aks_control_plane.principal_id
  role_definition_name             = "Managed Identity Operator"
  scope                            = azurerm_user_assigned_identity.aks_kubelet.id
  skip_service_principal_aad_check = true
}

# Grant kubelet identity permission to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_user_assigned_identity.aks_kubelet.principal_id
  role_definition_name             = "AcrPull"
  scope                            = module.container_registry.resource.id
  skip_service_principal_aad_check = true
}

module "aks_cluster" {
  source = "git::https://github.com/Azure/terraform-azurerm-avm-res-containerservice-managedcluster.git?ref=v0.3.0"

  default_node_pool = {
    name                 = "default"
    vm_size              = "Standard_DS2_v2"
    node_count           = 3
    min_count            = 3
    max_count            = 3
    auto_scaling_enabled = true
    vnet_subnet_id      = module.vnet.subnets["aks_subnet"].resource_id
    upgrade_settings = {
      max_surge = "10%"
    }
  }
  location            = var.azrm_resource_location
  name                = module.naming.kubernetes_cluster.name
  resource_group_name = module.resource_group.name
  azure_active_directory_role_based_access_control = {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }
  local_account_disabled = false
  dns_prefix = "automaticexample"
  maintenance_window_auto_upgrade = {
    frequency   = "Weekly"
    interval    = "1"
    day_of_week = "Sunday"
    duration    = 4
    utc_offset  = "+00:00"
    start_time  = "00:00"
    start_date  = "2024-10-15T00:00:00Z"
  }
  managed_identities = {
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.aks_control_plane.id
    ]
  }
  kubelet_identity = {
    client_id                 = azurerm_user_assigned_identity.aks_kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.aks_kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_kubelet.id
  }

  network_profile = {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  depends_on = [
    azurerm_role_assignment.aks_control_plane_mio
  ]
}