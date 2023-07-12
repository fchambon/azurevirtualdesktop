# Define variable for the location of the resource group
variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of the resource group."
}

# Define variable for the name of the resource group
variable "rg_name" {
  type        = string
  default     = "rg-avd-indus"
  description = "Name of the Resource group in which to deploy service objects"
}

# Define the number of session hosts to deploy
variable "vm_count" {
  type = number
  description = "Number of AVD machines to deploy"
  default     = 1
}

