########################################
# AZURE VIRTUAL DESKTOP NETWORKING
########################################

resource "random_integer" "vnet_int" {
  min = 1
  max = 30
  keepers = {
    rg = var.rg_name
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNet${random_integer.vnet_int.result}"
  address_space       = var.vnet_range
  location            = var.deploy_location
# dns_servers         = var.dns_servers # Uncomment if you want to use custom DNS servers
  resource_group_name = var.rg_name
  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-sub"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_range
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-NSG"
  location            = var.deploy_location
  resource_group_name = var.rg_name
  tags = var.tags
  security_rule {
    name                       = "HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Uncomment if you want to use an existing hub virtual network and create VNET peering

 data "azurerm_virtual_network" "hub_vnet_data" {
  count               = var.enable_peer == true ? 1 : 0  
  name                = var.hub_vnet
  resource_group_name = var.hub_rg
    }

 resource "azurerm_virtual_network_peering" "peer1" {
  count                     = var.enable_peer == true ? 1 : 0
  name                      = "peer_avdspoke_hub"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet_data[count.index].id
   allow_virtual_network_access = true
   allow_forwarded_traffic      = true
   allow_gateway_transit        = true
   use_remote_gateways          = true

   lifecycle {
     precondition {
         # This is required to ensure the peering is created after the hub vnet is created
         condition     = data.azurerm_virtual_network.hub_vnet_data[count.index].id != null
         error_message = "The hub vnet does not exist"
     }
   }
 }
 resource "azurerm_virtual_network_peering" "peer2" {
  count                     = var.enable_peer == true ? 1 : 0
  name                      = "peer_hub_avdspoke"
  resource_group_name       = var.hub_rg
  virtual_network_name      = var.hub_vnet
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
   allow_virtual_network_access = true
   allow_forwarded_traffic      = true
   allow_gateway_transit        = true
   use_remote_gateways          = false
   depends_on = [ 
    azurerm_virtual_network_peering.peer1 ]
 }
