# Proxmox Provider Variables
variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.local:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (e.g., terraform@pve!terraform-token)"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (set to true for self-signed certificates)"
  type        = bool
  default     = true
}

# Proxmox Node Configuration
variable "proxmox_node" {
  description = "Proxmox node name (e.g., pve, k10)"
  type        = string
  default     = "pve"
}

variable "proxmox_storage" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

# Test VM Configuration
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

variable "test_vm_template" {
  description = "Template/Clone source for test VM (ID or name)"
  type        = string
  default     = "ubuntu-22.04-cloudinit"
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
  description = "Disk size for test VM (e.g., 20G)"
  type        = string
  default     = "20G"
}

variable "test_vm_network_bridge" {
  description = "Network bridge for test VM"
  type        = string
  default     = "vmbr1"
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = ""
}

# Production VM Configuration
# OPNsense
variable "opnsense_enabled" {
  description = "Enable OPNsense VM creation"
  type        = bool
  default     = false  # Disabled by default, enable when ready
}

variable "opnsense_template" {
  description = "Template for OPNsense VM (optional, can use ISO)"
  type        = string
  default     = ""
}

# T-Pot Hive
variable "tpot_enabled" {
  description = "Enable T-Pot Hive VM creation"
  type        = bool
  default     = false
}

variable "tpot_template" {
  description = "Template for T-Pot VM (Debian 12 recommended)"
  type        = string
  default     = "debian-12-cloudinit"
}

# Malcolm
variable "malcolm_enabled" {
  description = "Enable Malcolm VM creation"
  type        = bool
  default     = false
}

variable "malcolm_template" {
  description = "Template for Malcolm VM (Ubuntu)"
  type        = string
  default     = "ubuntu-22.04-cloudinit"
}

# CTF Challenges
variable "ctf_enabled" {
  description = "Enable CTF Challenges VM creation"
  type        = bool
  default     = false
}

variable "ctf_template" {
  description = "Template for CTF VM (Ubuntu)"
  type        = string
  default     = "ubuntu-22.04-cloudinit"
}
