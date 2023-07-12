output "RG_Name" {
  description = "Name of the Resource group in which to deploy session host"
  value       = azurerm_resource_group.rg.name
}

output "Azure_Region" {
  description = "The Azure region"
  value       = module.avd.location
}

output "Vnet_Range" {
  description = "Address range for deployment vnet"
  value       = module.avd.vnetrange
}

output "Log_Analaytics_Workspace" {
  description = "Log Analytics Workspace Name"
  value       = module.avd.law
}

output "KeyVault" {
  description = "Azure KeyVault Name"
  value       = module.avd.keyvault
}

output "Compute_Gallery" {
  description = "Azure Compute Gallery Name"
  value       = module.avd.acg
}

output "FSLogix_Storage" {
  description = "Azure File Storage for FSLogix"
  value       = module.avd.storage
}

