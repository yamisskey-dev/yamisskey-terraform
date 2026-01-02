# Output values for test VM
output "test_vm_id" {
  description = "Test VM ID in Proxmox"
  value       = var.test_vm_enabled ? proxmox_virtual_environment_vm.test_vm[0].vm_id : null
}

output "test_vm_name" {
  description = "Test VM name"
  value       = var.test_vm_enabled ? proxmox_virtual_environment_vm.test_vm[0].name : null
}

output "test_vm_ipv4_addresses" {
  description = "Test VM IPv4 addresses (from QEMU guest agent)"
  value       = var.test_vm_enabled ? proxmox_virtual_environment_vm.test_vm[0].ipv4_addresses : null
}

# =============================================================================
# Production VM Outputs
# =============================================================================

# OPNsense
output "opnsense_id" {
  description = "OPNsense VM ID"
  value       = var.opnsense_enabled ? proxmox_virtual_environment_vm.opnsense[0].vm_id : null
}

output "opnsense_name" {
  description = "OPNsense VM name"
  value       = var.opnsense_enabled ? proxmox_virtual_environment_vm.opnsense[0].name : null
}

# T-Pot Hive
output "tpot_id" {
  description = "T-Pot Hive VM ID"
  value       = var.tpot_enabled ? proxmox_virtual_environment_vm.tpot[0].vm_id : null
}

output "tpot_name" {
  description = "T-Pot Hive VM name"
  value       = var.tpot_enabled ? proxmox_virtual_environment_vm.tpot[0].name : null
}

output "tpot_ipv4_addresses" {
  description = "T-Pot Hive VM IPv4 addresses"
  value       = var.tpot_enabled ? proxmox_virtual_environment_vm.tpot[0].ipv4_addresses : null
}

# Malcolm
output "malcolm_id" {
  description = "Malcolm VM ID"
  value       = var.malcolm_enabled ? proxmox_virtual_environment_vm.malcolm[0].vm_id : null
}

output "malcolm_name" {
  description = "Malcolm VM name"
  value       = var.malcolm_enabled ? proxmox_virtual_environment_vm.malcolm[0].name : null
}

output "malcolm_ipv4_addresses" {
  description = "Malcolm VM IPv4 addresses"
  value       = var.malcolm_enabled ? proxmox_virtual_environment_vm.malcolm[0].ipv4_addresses : null
}

# CTF Challenges
output "ctf_id" {
  description = "CTF Challenges VM ID"
  value       = var.ctf_enabled ? proxmox_virtual_environment_vm.ctf_challenges[0].vm_id : null
}

output "ctf_name" {
  description = "CTF Challenges VM name"
  value       = var.ctf_enabled ? proxmox_virtual_environment_vm.ctf_challenges[0].name : null
}

output "ctf_ipv4_addresses" {
  description = "CTF Challenges VM IPv4 addresses"
  value       = var.ctf_enabled ? proxmox_virtual_environment_vm.ctf_challenges[0].ipv4_addresses : null
}

# =============================================================================
# Summary Output
# =============================================================================
output "vm_summary" {
  description = "Summary of all VMs"
  value = {
    test_vm = var.test_vm_enabled ? {
      vm_id          = proxmox_virtual_environment_vm.test_vm[0].vm_id
      name           = proxmox_virtual_environment_vm.test_vm[0].name
      ipv4_addresses = proxmox_virtual_environment_vm.test_vm[0].ipv4_addresses
    } : null

    opnsense = var.opnsense_enabled ? {
      vm_id = proxmox_virtual_environment_vm.opnsense[0].vm_id
      name  = proxmox_virtual_environment_vm.opnsense[0].name
    } : null

    tpot = var.tpot_enabled ? {
      vm_id          = proxmox_virtual_environment_vm.tpot[0].vm_id
      name           = proxmox_virtual_environment_vm.tpot[0].name
      ipv4_addresses = proxmox_virtual_environment_vm.tpot[0].ipv4_addresses
    } : null

    malcolm = var.malcolm_enabled ? {
      vm_id          = proxmox_virtual_environment_vm.malcolm[0].vm_id
      name           = proxmox_virtual_environment_vm.malcolm[0].name
      ipv4_addresses = proxmox_virtual_environment_vm.malcolm[0].ipv4_addresses
    } : null

    ctf = var.ctf_enabled ? {
      vm_id          = proxmox_virtual_environment_vm.ctf_challenges[0].vm_id
      name           = proxmox_virtual_environment_vm.ctf_challenges[0].name
      ipv4_addresses = proxmox_virtual_environment_vm.ctf_challenges[0].ipv4_addresses
    } : null
  }
}
