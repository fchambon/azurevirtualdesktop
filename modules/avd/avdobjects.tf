##########################################################################################
# AZURE VIRTUAL DESKTOP OBJECTS - WORKSPACE APPLICATION GROUPS - HOSTPOOLS
##########################################################################################
# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.workspace
  resource_group_name = var.rg_name
  location            = var.deploy_location
  friendly_name       = "${var.prefix} Workspace"
  description         = "${var.prefix} Workspace"
  tags = var.tags
}

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  resource_group_name      = var.rg_name
  location                 = var.deploy_location
  name                     = var.hostpool
  friendly_name            = var.hostpool
  validate_environment     = false
  custom_rdp_properties    = "targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;enablerdsaadauth:i:1;"
  description              = "${var.prefix} Terraform HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = var.max_session
  load_balancer_type       = var.lb_type 
  tags = var.tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = timeadd(timestamp(), "6h")
#  expiration_date = var.rfc3339
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "dag" {
  resource_group_name = var.rg_name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  location            = var.deploy_location
  type                = "Desktop"
  default_desktop_display_name = var.dag_displayname
  name                = "${var.prefix}-dag"
  friendly_name       = "Desktop AppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.workspace]
  tags = var.tags
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}