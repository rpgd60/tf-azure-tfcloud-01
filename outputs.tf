output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip" {
  value = azurerm_linux_virtual_machine.tfub_vm.public_ip_address
}

output "private_ip" {
  value = azurerm_linux_virtual_machine.tfub_vm.private_ip_address
}

output "full_machine_name" {
  value = azurerm_public_ip.tfub_publicip.fqdn
}

output "vm_admin_user" {
  value = azurerm_linux_virtual_machine.tfub_vm.admin_username
}