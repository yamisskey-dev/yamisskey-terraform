# Output values for test VM
output "test_vm_id" {
  description = "Test VM ID in Proxmox"
  value       = var.test_vm_enabled ? proxmox_vm_qemu.test_vm[0].id : null
}

output "test_vm_ip" {
  description = "Test VM IP address (if available)"
  value       = var.test_vm_enabled ? proxmox_vm_qemu.test_vm[0].default_ipv4_address : null
}

output "test_vm_name" {
  description = "Test VM name"
  value       = var.test_vm_enabled ? proxmox_vm_qemu.test_vm[0].name : null
}

# Future outputs for production VMs
# output "pfsense_ip" { ... }
# output "tpot_ip" { ... }
# output "malcolm_ip" { ... }
# output "ctfd_ip" { ... }
