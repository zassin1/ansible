variable "subscription_id" {
  description = "Azure subscription ID used for deployment."
  type        = string
  default     = "c376c5da-f553-433b-8db3-72b61be70105"
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used for authentication."
  type        = string
  default     = "d5783933-d8d3-4c23-8256-4662298b20e9"
}

variable "location" {
  description = "Azure region for the resources."
  type        = string
  default     = "westus2"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-ansible-blog-dev"
}

variable "prefix" {
  description = "Short lowercase prefix used in Azure resource names."
  type        = string
  default     = "ansblog"
  validation {
    condition     = can(regex("^[a-z0-9-]{3,15}$", var.prefix))
    error_message = "prefix must contain 3-15 lowercase letters, numbers, or hyphens."
  }
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key installed on the VM."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the VM. Use your public IP/32 when possible."
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    project     = "ansible-blog-deployment"
    environment = "dev"
    managed_by  = "terraform"
  }
}
