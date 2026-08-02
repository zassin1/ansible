output "public_ip_address" {
  description = "Public IPv4 address of the Nginx VM."
  value       = azurerm_public_ip.web.ip_address
}

output "admin_username" {
  description = "SSH administrator username."
  value       = var.admin_username
}

output "website_url" {
  description = "Public URL of the deployed website."
  value       = "http://${azurerm_public_ip.web.ip_address}"
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}
