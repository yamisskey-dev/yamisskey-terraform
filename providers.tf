terraform {
  required_version = ">= 1.7.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

# Load secrets from SOPS-encrypted file
data "sops_file" "secrets" {
  source_file = "secrets.sops.yaml"
}

provider "proxmox" {
  endpoint  = data.sops_file.secrets.data["proxmox_api_url"]
  api_token = "${data.sops_file.secrets.data["proxmox_api_token_id"]}=${data.sops_file.secrets.data["proxmox_api_token_secret"]}"
  insecure  = data.sops_file.secrets.data["proxmox_tls_insecure"] == "true"
}
