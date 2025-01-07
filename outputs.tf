output "aws_vm_public_ip" {
  value = aws_instance.test_vm.public_ip
}

output "azure_vm_public_ip" {
  value = azurerm_public_ip.test_vm.ip_address
}

output "aws_vm_private_ip" {
  value = aws_instance.test_vm.private_ip
}

output "azure_vm_private_ip" {
  value = azurerm_network_interface.test_vm.private_ip_address
}