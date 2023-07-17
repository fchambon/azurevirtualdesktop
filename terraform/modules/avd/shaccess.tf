###################################################
# AZURE VIRTUAL DESKTOP - PERMISSIONS
###################################################

resource "azurerm_role_assignment" "vm_user_role" {
  scope              = var.rg_id
  role_definition_id = var.vm_user_login
  principal_id       = var.aad_group
}

resource "azurerm_role_assignment" "desktop_role" {
  scope              = azurerm_virtual_desktop_application_group.dag.id
  role_definition_id = var.desktop_user
  principal_id       = var.aad_group
}
