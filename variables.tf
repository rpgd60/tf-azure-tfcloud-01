
variable "region" {
  type        = string
  default     = "westeurope"
  description = "Region for Location of the resource group."
}

variable "app_name" {
  type        = string
  default     = "tfcloud-1"
  description = "Application / Workload name"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Workload environment"
}

variable "cost_center" {
  type        = string
  description = "Cost Center for workload"
  default     = "00000"
}

## VM Parameters
variable "vm_size" {
  type        = string
  description = "VM Size"
  default     = "Standard_DS1_v2"
}

variable "ssh_user" {
  type        = string
  description = "Username for ssh to VM"
  default     = "azureuser"
}

variable "ssh_pub_key_file" {
  type        = string
  description = "file for SSH public key"
  default     = "~/.ssh/mykey.pub"
}

variable "dns_name" {
  type        = string
  default     = "vm-test1"
  description = "Host name"
}