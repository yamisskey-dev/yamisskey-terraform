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

  # Console: std VGA (changed from serial0 inherited by cloud-init template)
  vga {
    type = "std"
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
# Home Assistant OS - Smart Home Platform
# =============================================================================
# Automated deployment: SSH to Proxmox host to download/extract HAOS qcow2.xz,
# then create the VM referencing the imported image.
# Requires: SSH key-based access to Proxmox host (root@proxmox_host).

# Step 1: Download HAOS image and create VM via qm commands on Proxmox host.
# This bypasses the provider's SSH-based file_id import which is incompatible
# with Windows SSH agent forwarded to WSL2.
resource "terraform_data" "haos_provision" {
  count = var.haos_enabled ? 1 : 0

  triggers_replace = [var.haos_version]

  provisioner "local-exec" {
    command = <<-EOT
      ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519_mary -o StrictHostKeyChecking=accept-new root@${var.proxmox_host} '
        set -e
        VMID=105
        IMG="/var/lib/vz/template/iso/haos_ova-${var.haos_version}.qcow2"

        # Download image if not present
        if [ ! -f "$IMG" ]; then
          echo "Downloading HAOS ${var.haos_version}..."
          wget -q -O /tmp/haos.qcow2.xz \
            "https://github.com/home-assistant/operating-system/releases/download/${var.haos_version}/haos_ova-${var.haos_version}.qcow2.xz"
          echo "Extracting..."
          xz -d /tmp/haos.qcow2.xz
          mv /tmp/haos.qcow2 "$IMG"
          echo "Done: $IMG"
        else
          echo "Image already exists: $IMG"
        fi

        # Create VM if not exists
        if ! qm status $VMID >/dev/null 2>&1; then
          echo "Creating VM $VMID..."
          qm create $VMID \
            --name haos \
            --bios ovmf \
            --machine q35 \
            --cpu host \
            --cores ${var.haos_cores} \
            --memory ${var.haos_memory} \
            --net0 virtio,bridge=vmbr1 \
            --scsihw virtio-scsi-pci \
            --agent 1 \
            --onboot 1 \
            --tags "terraform;production;homeassistant"

          echo "Importing disk..."
          qm set $VMID --scsi0 ${var.proxmox_storage}:0,import-from=$IMG,discard=on,ssd=1
          qm set $VMID --boot order=scsi0

          echo "Starting VM..."
          qm start $VMID
          echo "HAOS VM $VMID created and started."
        else
          echo "VM $VMID already exists, skipping creation."
        fi
      '
    EOT
  }
}

# Step 2: Manage the VM created by the provisioner above.
# After first `terraform apply`, run:
#   terraform import 'proxmox_virtual_environment_vm.haos[0]' mary/105
resource "proxmox_virtual_environment_vm" "haos" {
  count      = var.haos_enabled ? 1 : 0
  depends_on = [terraform_data.haos_provision]

  name        = "haos"
  description = "Home Assistant OS - Smart home platform on LAN segment"
  node_name   = var.proxmox_node
  tags        = ["terraform", "production", "homeassistant"]
  vm_id       = 105

  agent {
    enabled = true
    timeout = "30s"
  }

  cpu {
    cores = var.haos_cores
    type  = "host"
  }

  memory {
    dedicated = var.haos_memory
  }

  disk {
    datastore_id = var.proxmox_storage
    interface    = "scsi0"
    size         = var.haos_disk_size
    discard      = "on"
    ssd          = true
  }

  # LAN network - same segment as OpenClaw for API integration
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  bios    = "ovmf"
  machine = "q35"

  on_boot = true

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      disk,    # HAOS auto-resizes disk on first boot
      started,
    ]
  }
}
