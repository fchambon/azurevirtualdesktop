resource "random_string" "azurerm_key_vault_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "random_password" "vm-password" {
    length           = 16
    special          = true
    override_special = "*!@#?"
}

resource "azurerm_key_vault" "vault" {
  name                       = "vault-${random_string.azurerm_key_vault_name.result}"
  location                   = var.deploy_location
  resource_group_name        = var.rg_name
  tenant_id                  = var.tenantid
  sku_name                   = var.sku_name
  tags = var.tags
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = var.tenantid
    object_id = var.objectid

    key_permissions    = var.key_permissions
    secret_permissions = var.secret_permissions
  }
}

resource "azurerm_key_vault_secret" "kv-vm-secret" {
    key_vault_id = azurerm_key_vault.vault.id
    name = var.vmsecretpwd
    value = random_password.vm-password.result
}