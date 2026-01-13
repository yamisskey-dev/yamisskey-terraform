# Proxmox Node Configuration
# Note: API credentials are loaded from secrets.sops.yaml via SOPS provider

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "mary"
}

variable "proxmox_storage" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

# =============================================================================
# Test VM Configuration
# =============================================================================
variable "test_vm_enabled" {
  description = "Enable test VM creation (for initial validation)"
  type        = bool
  default     = true
}

variable "test_vm_name" {
  description = "Name of test VM"
  type        = string
  default     = "terraform-test"
}

variable "test_vm_template_id" {
  description = "Template VM ID for cloning (e.g., 9000)"
  type        = number
  default     = 9000
}

variable "test_vm_cores" {
  description = "Number of CPU cores for test VM"
  type        = number
  default     = 2
}

variable "test_vm_memory" {
  description = "Memory in MB for test VM"
  type        = number
  default     = 2048
}

variable "test_vm_disk_size" {
  description = "Disk size in GB for test VM"
  type        = number
  default     = 20
}

variable "test_vm_network_bridge" {
  description = "Network bridge for test VM"
  type        = string
  default     = "vmbr0"
}

# =============================================================================
# OPNsense - Router/Firewall
# =============================================================================
variable "opnsense_enabled" {
  description = "Enable OPNsense VM creation"
  type        = bool
  default     = false
}

variable "opnsense_iso" {
  description = "OPNsense ISO file ID (e.g., local:iso/OPNsense-25.1-dvd-amd64.iso)"
  type        = string
  default     = "local:iso/OPNsense-25.1-dvd-amd64.iso"
}

# =============================================================================
# T-Pot Hive - Honeypot Platform
# =============================================================================
variable "tpot_enabled" {
  description = "Enable T-Pot Hive VM creation"
  type        = bool
  default     = false
}

variable "tpot_template_id" {
  description = "Template VM ID for T-Pot (Debian 12)"
  type        = number
  default     = 9001
}

# =============================================================================
# CTFd - CTF Platform
# =============================================================================
variable "ctf_enabled" {
  description = "Enable CTF Challenges VM creation"
  type        = bool
  default     = false
}

variable "ctf_template_id" {
  description = "Template VM ID for CTF (Ubuntu)"
  type        = number
  default     = 9000
}
