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

# Production VM outputs

# OPNsense
output "opnsense_id" {
  description = "OPNsense VM ID"
  value       = var.opnsense_enabled ? proxmox_vm_qemu.opnsense[0].id : null
}

output "opnsense_name" {
  description = "OPNsense VM name"
  value       = var.opnsense_enabled ? proxmox_vm_qemu.opnsense[0].name : null
}

# T-Pot Hive
output "tpot_id" {
  description = "T-Pot Hive VM ID"
  value       = var.tpot_enabled ? proxmox_vm_qemu.tpot[0].id : null
}

output "tpot_ip" {
  description = "T-Pot Hive VM IP address"
  value       = var.tpot_enabled ? proxmox_vm_qemu.tpot[0].default_ipv4_address : null
}

output "tpot_name" {
  description = "T-Pot Hive VM name"
  value       = var.tpot_enabled ? proxmox_vm_qemu.tpot[0].name : null
}

# Malcolm
output "malcolm_id" {
  description = "Malcolm VM ID"
  value       = var.malcolm_enabled ? proxmox_vm_qemu.malcolm[0].id : null
}

output "malcolm_ip" {
  description = "Malcolm VM IP address"
  value       = var.malcolm_enabled ? proxmox_vm_qemu.malcolm[0].default_ipv4_address : null
}

output "malcolm_name" {
  description = "Malcolm VM name"
  value       = var.malcolm_enabled ? proxmox_vm_qemu.malcolm[0].name : null
}

# CTF Challenges
output "ctf_id" {
  description = "CTF Challenges VM ID"
  value       = var.ctf_enabled ? proxmox_vm_qemu.ctf_challenges[0].id : null
}

output "ctf_ip" {
  description = "CTF Challenges VM IP address"
  value       = var.ctf_enabled ? proxmox_vm_qemu.ctf_challenges[0].default_ipv4_address : null
}

output "ctf_name" {
  description = "CTF Challenges VM name"
  value       = var.ctf_enabled ? proxmox_vm_qemu.ctf_challenges[0].name : null
}

# Summary output
output "vm_summary" {
  description = "Summary of all VMs"
  value = {
    test_vm = var.test_vm_enabled ? {
      id   = proxmox_vm_qemu.test_vm[0].id
      ip   = proxmox_vm_qemu.test_vm[0].default_ipv4_address
      name = proxmox_vm_qemu.test_vm[0].name
    } : null

    opnsense = var.opnsense_enabled ? {
      id   = proxmox_vm_qemu.opnsense[0].id
      name = proxmox_vm_qemu.opnsense[0].name
    } : null

    tpot = var.tpot_enabled ? {
      id   = proxmox_vm_qemu.tpot[0].id
      ip   = proxmox_vm_qemu.tpot[0].default_ipv4_address
      name = proxmox_vm_qemu.tpot[0].name
    } : null

    malcolm = var.malcolm_enabled ? {
      id   = proxmox_vm_qemu.malcolm[0].id
      ip   = proxmox_vm_qemu.malcolm[0].default_ipv4_address
      name = proxmox_vm_qemu.malcolm[0].name
    } : null

    ctf = var.ctf_enabled ? {
      id   = proxmox_vm_qemu.ctf_challenges[0].id
      ip   = proxmox_vm_qemu.ctf_challenges[0].default_ipv4_address
      name = proxmox_vm_qemu.ctf_challenges[0].name
    } : null
  }
}
