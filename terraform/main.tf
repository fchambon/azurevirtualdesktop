###################################################
# AZURE VIRTUAL DESKTOP - ENTRY POINT
###################################################

# Get Azure AD Users Group information
data "azuread_group" "aad_group" {
  display_name = "AVDUsers"
}
data "azurerm_role_definition" "vm_user_login" {
  name = "Virtual Machine User Login"
}

data "azurerm_role_definition" "desktop_user" { 
  name = "Desktop Virtualization User"
}

# Get AzureRM provider current configuration 
data "azurerm_client_config" "current" {}

# Resource group name is output when execution plan is applied.
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.resource_group_location
}

module "avd" {
    source = "./modules/avd"
    rg_name = azurerm_resource_group.rg.name
    rg_id = azurerm_resource_group.rg.id
    sh_count = var.vm_count
    deploy_location = azurerm_resource_group.rg.location
    aad_group = data.azuread_group.aad_group.id
    tenantid = data.azurerm_client_config.current.tenant_id
    objectid = data.azurerm_client_config.current.object_id
    vm_user_login = data.azurerm_role_definition.vm_user_login.id
    desktop_user = data.azurerm_role_definition.desktop_user.id
    depends_on = [azurerm_resource_group.rg]
}