###################################################
# AZURE VIRTUAL DESKTOP - RG
###################################################

# Define variable for the name of the resource group
variable "rg_name" {
  type        = string
  default     = "rg-avd-indus"
  description = "Name of the Resource group in which to deploy service objects"
}

# Define variable for the AVD deployment locations
variable "deploy_location" {
  type        = string
  default     = "westeurope"
  description = "The Azure Region in which all resources in this example should be created."
}

###################################################
# AZURE VIRTUAL DESKTOP - KeyVault
###################################################

variable "tenantid" {
  type        = string
  description = "The Azure TenantID"
}

variable "objectid" {
  type        = string
  description = "The current objectID"
}

variable "sku_name" {
  type        = string
  description = "The SKU of the vault to be created."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Set", "Get"]
}

variable "vmsecretpwd"{
    default = "vm-password"
    description = "value of the secret"
}

###################################################
# NETWORKING
###################################################
# Define variables for the AVD virtual network
variable "vnet-name" {
  type        = string
  default     = "avd-tf-vnet"
  description = "Name of the virtual network"
}

variable "vnet_range" {
  type        = list(string)
  default     = ["10.2.0.0/16"]
  description = "Address range for deployment VNet"
}
variable "subnet_range" {
  type        = list(string)
  default     = ["10.2.0.0/24"]
  description = "Address range for session host subnet"
}

# Uncomment if you want to use custom DNS servers
# variable "dns_servers" {
# type        = list(string)
# default     = ["10.0.1.4", "168.63.129.16"]
# description = "Custom DNS configuration"
# }

#Uncomment if you want to peer to an existing Vnet
variable "enable_peer" {
  type        = bool
  default     = false
  description = "Enable peering to an existing Vnet"
}

#Fill in the following variables if you want to peer to an existing Vnet
variable "hub_vnet" {
type        = string
default     = "VNET-HUB"
description = "Name of hub vnet"
}

variable "hub_rg" {
type        = string
default     = "RG-HUB-VNET"
description = "Resource Group of hub vnet"
}

###################################################
# AZURE VIRTUAL DESKTOP - OBJECTS
###################################################
# Define variable for the name of the Azure Virtual Desktop workspace
variable "workspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
  default     = "AVD TF Workspace" 
}

# Define variable for the name of the Azure Virtual Desktop host pool
variable "hostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
  default     = "AVD-TF-HP"
}

# Define variable for the maximum number of sessions per host
variable "max_session" {
  type        = string
  description = "Maximum number of sessions per host"
  default     = 12
}

variable "lb_type" {
  type        = string
  description = "Load Balancer type"
  default     = "DepthFirst" #[BreadthFirst DepthFirst]
}


# Define variable for the registration token expiration
variable "rfc3339" {
  type        = string
  default     = "2023-07-30T12:43:13Z"
  description = "Registration token expiration"
}

# Define variable for the prefix of the name of the AVD objects
variable "prefix" {
  type        = string
  default     = "avdtf"
  description = "Prefix of the name of the AVD machine(s)"
}

variable "dag_displayname" {
    type = string
    default = "My Cloud PC"
    description = "Display name of the AVD Desktop Application Group"
}

###################################################
# AZURE VIRTUAL DESKTOP - SESSION HOSTS
###################################################
# Define the number of session hosts to deploy
variable "sh_count" {
  type = number
  description = "Number of AVD machines to deploy"
}
# Define the VM size for the session hosts
variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_D2as_v5"
}

variable "local_admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  default     = "ChangeMe123!"
  description = "local admin password"
  sensitive   = true
}

###################################################
# AZURE VIRTUAL DESKTOP - FSLOGIX STORAGE
###################################################

variable "fslogix_share_name" {
    type        = string
    description = "Name of the fslogix SMB share"
    default     = "fslogix"
}

variable "fslogix_quota" {
    type        = number
    description = "Default quota for FSlogix share"
    default     = "100" #GB
}

###################################################
# AZURE VIRTUAL DESKTOP - PERMISSIONS
###################################################

variable "rg_id" {
  type        = string
  description = "Resource Group ID"
}

variable "aad_group" {
  type        = string
  description = "Azure AD group ID to assign to the AVD DAG"
}

variable "vm_user_login" {
  type        = string
  description = "Azure Role Definition ID for the VM User Login" #Required for AAD joined session hosts
}

variable "desktop_user" {
  type        = string
  description = "Azure Role Definition ID for the Desktop User" 
}


###################################################
# AZURE VIRTUAL DESKTOP - TAGS
###################################################

variable "tags" {
    type        = map(string)
    description = "Tags to apply to all resources in this example"
    default     = {
        environment = "Demo"
        costcenter  = "it2023"
        protection-level  = "standard"
        availability-level = "gold"
    }
}