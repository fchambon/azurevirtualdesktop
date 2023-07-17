resource "random_string" "acgrandom" {
  length  = 4
  upper   = false
  special = false
}

# Creates Shared Image Gallery
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery
resource "azurerm_shared_image_gallery" "acg" {
  name                = "acg${random_string.acgrandom.id}"
  resource_group_name = var.rg_name
  location            = var.deploy_location
  description         = "Shared Image Gallery for AVD"
  tags = var.tags
}

#Creates image definition
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image
resource "azurerm_shared_image" "example" {
  name                = "avd-image"
  gallery_name        = azurerm_shared_image_gallery.acg.name
  resource_group_name = var.rg_name
  location            = var.deploy_location
  os_type             = "Windows"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "win11-22h2-avd-m365" #Multi-session SKU
  }
}