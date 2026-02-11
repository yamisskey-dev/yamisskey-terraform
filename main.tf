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
  vm_id       = 101

  # Boot from ISO for initial installation
  cdrom {
    enabled   = true
    file_id   = var.opnsense_iso
    interface = "ide2"
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = 32
    interface    = "scsi0"
    file_format  = "raw"
  }

  # net0/vtnet0 - LAN (OPNsense assigns interfaces internally)
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  # net1/vtnet1 - DMZ
  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  # net2/vtnet2 - WAN
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  bios    = "seabios"
  on_boot = true
  started = false # Don't auto-start, manual install required

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      cdrom, # Allow removing ISO after install
      started,
      kvm_arguments, # Manually set, API token cannot modify 'args'
      cpu,           # CPU type configured during OPNsense install
    ]
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

  agent {
    enabled = true
    timeout = "30s"
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
    user_account {
      username = data.sops_file.secrets.data["vm_credentials.tpot.username"]
      password = data.sops_file.secrets.data["vm_credentials.tpot.password"]
    }
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
# CTFd - CTF Platform
# =============================================================================
resource "proxmox_virtual_environment_vm" "ctfd" {
  count = var.ctf_enabled ? 1 : 0

  name        = "ctfd"
  description = "CTFd - CTF platform with Docker Compose"
  node_name   = var.proxmox_node
  tags        = ["terraform", "production", "ctf"]
  vm_id       = 103

  # clone block removed: VM was imported from existing Proxmox VM
  # To recreate, re-add: clone { vm_id = var.ctf_template_id }

  agent {
    enabled = true
    timeout = "30s"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = 40
    interface    = "scsi0"
  }

  # DMZ network for isolation
  network_device {
    bridge = "vmbr2"
  }

  initialization {
    user_account {
      username = data.sops_file.secrets.data["vm_credentials.ctfd.username"]
      password = data.sops_file.secrets.data["vm_credentials.ctfd.password"]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  on_boot = false # On-demand: start for CTF events

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      initialization,
    ]
  }
}

# =============================================================================
# OpenClaw - Autonomous AI agent isolated environment
# =============================================================================
resource "proxmox_virtual_environment_vm" "openclaw" {
  count = var.openclaw_enabled ? 1 : 0

  name        = "openclaw"
  description = "OpenClaw - Autonomous AI agent isolated on LAN segment"
  node_name   = var.proxmox_node
  tags        = ["terraform", "production", "openclaw"]
  vm_id       = 104

  clone {
    vm_id = var.openclaw_template_id
  }

  agent {
    enabled = true
    timeout = "30s"
  }

  cpu {
    cores = var.openclaw_cores
    type  = "host"
  }

  memory {
    dedicated = var.openclaw_memory
  }

  disk {
    datastore_id = var.proxmox_storage
    size         = var.openclaw_disk_size
    interface    = "scsi0"
  }

  # LAN network - isolated segment (formerly GOAD)
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  initialization {
    user_account {
      username = data.sops_file.secrets.data["vm_credentials.openclaw.username"]
      password = data.sops_file.secrets.data["vm_credentials.openclaw.password"]
    }
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
