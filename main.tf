# Main Terraform Configuration
# This is a minimal mock configuration for testing Proxmox connectivity

# Test VM Resource (minimal configuration)
resource "proxmox_vm_qemu" "test_vm" {
  count = var.test_vm_enabled ? 1 : 0

  name        = var.test_vm_name
  target_node = var.proxmox_node
  clone       = var.test_vm_template

  # VM Specifications
  cores   = var.test_vm_cores
  sockets = 1
  memory  = var.test_vm_memory

  # Disk Configuration
  disk {
    size    = var.test_vm_disk_size
    storage = var.proxmox_storage
    type    = "scsi"
  }

  # Network Configuration
  network {
    model  = "virtio"
    bridge = var.test_vm_network_bridge
  }

  # Cloud-init Configuration (optional)
  os_type = "cloud-init"

  # SSH key injection (if provided)
  sshkeys = var.ssh_public_key != "" ? var.ssh_public_key : null

  # Lifecycle settings
  lifecycle {
    # Prevent accidental destruction
    # prevent_destroy = true
  }

  # Tags for organization
  tags = "terraform,test"
}

# Future VM resources will be added here
# resource "proxmox_vm_qemu" "pfsense" { ... }
# resource "proxmox_vm_qemu" "tpot" { ... }
# resource "proxmox_vm_qemu" "malcolm" { ... }
# resource "proxmox_vm_qemu" "ctfd" { ... }
