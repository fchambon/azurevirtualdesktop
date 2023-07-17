output "location" {
  description = "The Azure region"
  value       = azurerm_virtual_network.vnet.location
}

output "vnetrange" {
  description = "Address range for deployment vnet"
  value       = azurerm_virtual_network.vnet.address_space
}

output "law" {
  description = "Log Analytics Workspace Name"
  value       = azurerm_log_analytics_workspace.law.name
}

output "keyvault" {
  description = "Azure KeyVault Name"
  value = azurerm_key_vault.vault.name
}

output "acg" {
  description = "Azure Compute Gallery"
  value       = azurerm_shared_image_gallery.acg.name
}

output "storage" {
  description = "Azure Storage"
  value       = azurerm_storage_account.storage.name
}