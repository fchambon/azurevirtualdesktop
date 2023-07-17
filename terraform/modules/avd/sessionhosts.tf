###################################################
# AZURE VIRTUAL DESKTOP - SESSION HOSTS
###################################################
locals {
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  commandtorun         = "New-Item -Path HKLM:/SOFTWARE/Microsoft/RDInfraAgent/AADJPrivate"
  powershell_command   = "${local.commandtorun}; ${local.shutdown_command}; ${local.exit_code_hack}"
}
resource "random_string" "AVD_local_password" {
  count            = var.sh_count
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}

resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.sh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = var.rg_name
  location            = var.deploy_location
  tags = var.tags

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.sh_count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = var.rg_name
  location              = var.deploy_location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = azurerm_key_vault_secret.kv-vm-secret.value
  license_type          = "Windows_Client"
  tags = var.tags

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {  
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-22h2-avd"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_network_interface.avd_vm_nic,
    azurerm_key_vault.vault
  ]
}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.sh_count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}",
        "aadJoin":true
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_desktop_host_pool.hostpool
  ]
}

resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
    count = var.sh_count
    name                              = "AADLoginForWindows"
    virtual_machine_id   = element(azurerm_windows_virtual_machine.avd_vm.*.id, count.index)
    publisher                         = "Microsoft.Azure.ActiveDirectory"
    type                              = "AADLoginForWindows"
    type_handler_version              = "1.0"
    auto_upgrade_minor_version        = true
    
    settings = <<SETTINGS
    {
        "mdmId" : "0000000a-0000-0000-c000-000000000000"
    }
    SETTINGS
    depends_on = [
        azurerm_virtual_machine_extension.vmext_dsc
    ]
}

resource "azurerm_virtual_machine_extension" "addaadjprivate-RemoteDesktop" {
    depends_on = [
      azurerm_virtual_machine_extension.AADLoginForWindows
    ]
  count                = var.sh_count
  name                 = "AADJPRIVATE"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "ama" {
    depends_on = [
      azurerm_log_analytics_workspace.law
    ]
 count                      = var.sh_count
 name                       = "${var.prefix}${count.index + 1}-avd_ama"
 virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
 publisher            = "Microsoft.Azure.Monitor"
 type                 = "AzureMonitorWindowsAgent"
 type_handler_version       = "1.10"
 auto_upgrade_minor_version = "true"
 settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
SETTINGS
   protected_settings = <<PROTECTED_SETTINGS
   {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
   }
PROTECTED_SETTINGS
}
