resource "random_string" "rlaw" {
  length           = 8
  special          = false
  upper            = false
}

# Creates Log Anaylytics Workspace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "log${random_string.rlaw.result}"
  location            = var.deploy_location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = var.tags
}

resource "azurerm_monitor_data_collection_rule" "rule1" {
 name                = "avd-rule1"
 location            = var.deploy_location
 resource_group_name = var.rg_name

 
 destinations {
   log_analytics {
     workspace_resource_id = azurerm_log_analytics_workspace.law.id
     name                  = "log-analytics"
   }
 }
 
 data_flow {
   streams      = ["Microsoft-Event"]
   destinations = ["log-analytics"]
 }

data_flow {
   streams      = ["Microsoft-InsightsMetrics", "Microsoft-Perf"]
   destinations = ["log-analytics"]
  }
 
 data_sources {
   windows_event_log {
     streams = ["Microsoft-Event"]
     x_path_queries = ["Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]",
       "Security!*[System[(band(Keywords,13510798882111488))]]",
     "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]"]
     name = "eventLogsDataSource"
   }

   performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["Processor(*)\\% Processor Time", "System\\Processes", "Memory\\Available Bytes", "LogicalDisk(_Total)\\% Free Space"]
      name                          = "test-datasource-perfcounter"
    }

 }
}

# Data collection rule association
 
resource "azurerm_monitor_data_collection_rule_association" "dcra1" {
 count                   = var.sh_count
 name                    = join("-", [var.prefix, count.index + 1, "dcra"])
 target_resource_id      = element(azurerm_windows_virtual_machine.avd_vm.*.id, count.index)
 data_collection_rule_id = azurerm_monitor_data_collection_rule.rule1.id
 depends_on = [ 
    azurerm_windows_virtual_machine.avd_vm
     ]
}