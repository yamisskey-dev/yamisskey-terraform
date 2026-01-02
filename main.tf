# Proxmox VE Virtual Machines for yamisskey infrastructure
# Using bpg/proxmox provider (Proxmox 9.x compatible)

# =============================================================================
# Test VM - For initial validation
# =============================================================================
resource "proxmox_virtual_environment_vm" "test_vm" {
  count = var.test_vm_enabled ? 1 : 0

  name        = var.test_vm_name
  description = "Terraform test VM for validation"
  node_name   = var.proxmox_node
  tags        = ["terraform", "test"]

  clone {
    vm_id = var.test_vm_template_id
  }

  cpu {
    cores = var.test_vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.test_vm_memory
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = var.test_vm_disk_size
    interface    = "scsi0"
  }

  network_device {
    bridge = var.test_vm_network_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      initialization,
    ]
  }
}

# =============================================================================
# OPNsense - Router/Firewall
# =============================================================================
resource "proxmox_virtual_environment_vm" "opnsense" {
  count = var.opnsense_enabled ? 1 : 0

  name        = "opnsense"
  description = "OPNsense Router/Firewall with HAProxy and WireGuard"
  node_name   = var.proxmox_node
  tags        = ["terraform", "production", "network"]

  # OPNsense requires manual ISO install, no clone
  # After first boot, convert to template or manage via Ansible

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = 32
    interface    = "scsi0"
  }

  # WAN - External network
  network_device {
    bridge = "vmbr0"
  }

  # LAN - Internal network
  network_device {
    bridge = "vmbr1"
  }

  # DMZ - Security research zone
  network_device {
    bridge = "vmbr2"
  }

  # Management network
  network_device {
    bridge = "vmbr3"
  }

  bios    = "seabios"
  on_boot = true

  lifecycle {
    prevent_destroy = true
  }
}

# =============================================================================
# T-Pot Hive - Honeypot Platform (full ELK stack)
# =============================================================================
resource "proxmox_virtual_environment_vm" "tpot" {
  count = var.tpot_enabled ? 1 : 0

  name        = "tpot"
  description = "T-Pot Hive - Honeypot platform with full ELK stack"
  node_name   = var.proxmox_node
  tags        = ["terraform", "production", "security"]

  clone {
    vm_id = var.tpot_template_id
  }

  cpu {
    cores = 8
    type  = "host"
  }

  memory {
    dedicated = 16384
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = 256
    interface    = "scsi0"
  }

  # DMZ network for honeypot exposure
  network_device {
    bridge = "vmbr2"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  on_boot = true

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      initialization,
    ]
  }
}

# =============================================================================
# Malcolm - Network Traffic Analysis
# =============================================================================
resource "proxmox_virtual_environment_vm" "malcolm" {
  count = var.malcolm_enabled ? 1 : 0

  name        = "malcolm"
  description = "Malcolm - Network traffic analysis (Zeek, Suricata, PCAP)"
  node_name   = var.proxmox_node
  tags        = ["terraform", "production", "security"]

  clone {
    vm_id = var.malcolm_template_id
  }

  cpu {
    cores = 12
    type  = "host"
  }

  memory {
    dedicated = 24576
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = 500
    interface    = "scsi0"
  }

  # DMZ network for traffic capture
  network_device {
    bridge = "vmbr2"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  on_boot = true

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      initialization,
    ]
  }
}

# =============================================================================
# CTF Challenges - Isolated CTF Environment
# =============================================================================
resource "proxmox_virtual_environment_vm" "ctf_challenges" {
  count = var.ctf_enabled ? 1 : 0

  name        = "ctf-challenges"
  description = "Isolated CTF challenge execution environment"
  node_name   = var.proxmox_node
  tags        = ["terraform", "production", "ctf"]

  clone {
    vm_id = var.ctf_template_id
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = 100
    interface    = "scsi0"
  }

  # DMZ network for isolation
  network_device {
    bridge = "vmbr2"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  on_boot = false

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      initialization,
    ]
  }
}
