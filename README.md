# yamisskey-terraform

Terraform configuration for managing Proxmox VE virtual machines in the yamisskey infrastructure.

## Overview

This project handles VM provisioning for the security research and CTF environment running on Proxmox VE (GMKtec NucBox K10). For the complete infrastructure overview, see [yamisskey-host](https://github.com/yamisskey-dev/yamisskey-host).

### Managed VMs

| VM | vCPU | RAM | Disk | Purpose |
|----|------|-----|------|---------|
| **pfSense** | 4c | 4GB | 32GB | Router, Firewall, HAProxy, OpenVPN |
| **T-Pot (Sensor)** | 8c | 8GB | 128GB | Honeypot sensors (Cowrie, Dionaea, ElasticPot) - no ELK |
| **Malcolm** | 12c | 24GB | 500GB | Network analysis (Zeek, Suricata, ELK) + T-Pot log analysis |
| **CTF-Challenges** | 4c | 4GB | 100GB | Isolated CTF challenge execution environment |

**Total allocation**: 28 vCPU, 40GB RAM (leaving 24GB for Proxmox host and overhead)

**Notes**:
- CTFd platform (web UI, scoreboard) runs on balthasar/caspar servers via Docker
- T-Pot runs in Sensor mode (honeypots only, no ELK stack)
- Malcolm's ELK stack analyzes both network traffic and T-Pot honeypot logs
- Configuration based on official requirements: [T-Pot](https://github.com/telekom-security/tpotce), [Malcolm](https://github.com/cisagov/Malcolm/blob/main/docs/system-requirements.md), [pfSense](https://docs.netgate.com/pfsense/en/latest/hardware/size.html)

### Separation of Concerns

- **Terraform** (this project): VM creation, resource allocation, network topology
- **Ansible** ([yamisskey-ansible](https://github.com/yamisskey-dev/yamisskey-ansible)): OS configuration, application deployment

## Prerequisites

### 1. Create Proxmox Cloud-init Template

```bash
# SSH to Proxmox host
ssh root@proxmox.local

# Download Ubuntu 22.04 cloud image
wget https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img

# Create template VM
qm create 9000 --name ubuntu-22.04-cloudinit --memory 2048 --cores 2 --net0 virtio,bridge=vmbr1
qm importdisk 9000 ubuntu-22.04-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000
```

### 2. Create Proxmox API Token

In Proxmox Web UI:
- Navigate to: **Datacenter → Permissions → API Tokens → Add**
- Token ID: `terraform@pve!terraform-token`
- Uncheck "Privilege Separation"
- Save the secret (you won't see it again)

### 3. Install Terraform

```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

## Quick Start

### 1. Configure Credentials

```bash
# Copy example files
cp .env.example .env
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano .env
nano terraform.tfvars
```

**Important**: Update these values in `terraform.tfvars`:
- `proxmox_api_token_secret`: Your actual API token
- `proxmox_node`: Your Proxmox node name (run `pvesh get /nodes` to check)
- `test_vm_template`: Template name (e.g., `ubuntu-22.04-cloudinit`)

### 2. Initialize & Test

```bash
# Load environment variables
source .env

# Initialize Terraform
terraform init

# Test Proxmox connectivity
curl -k -H "Authorization: PVEAPIToken=${PM_API_TOKEN_ID}=${PM_API_TOKEN_SECRET}" \
  "${PM_API_URL}/version"

# Plan test VM creation
terraform plan

# Create test VM
terraform apply
```

### 3. Verify & Cleanup

```bash
# Check outputs
terraform output

# Destroy test VM after verification
terraform destroy
```

## State Management

State is stored in Cloudflare R2 bucket with versioning enabled:

```hcl
terraform {
  backend "s3" {
    bucket = "yamisskey-terraform-state"
    key    = "production/terraform.tfstate"
    region = "auto"

    endpoints = {
      s3 = "https://<account_id>.r2.cloudflarestorage.com"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}
```

## Security Best Practices

1. Never commit `.env` files or credentials
2. Use API tokens with minimum required permissions
3. Enable state encryption at rest (R2 encryption)
4. Rotate API tokens regularly
5. Review `terraform plan` output before applying
6. Use workspaces for environment separation
7. Enable audit logging in Proxmox and Cloudflare

## Integration with yamisskey-ansible

After Terraform provisions infrastructure:

```bash
# 1. Terraform creates VMs
cd yamisskey-terraform
terraform apply

# 2. Ansible configures VMs
cd ../yamisskey-ansible
task run PLAYBOOK=pfsense
```

## Troubleshooting

### Proxmox API connection fails
```bash
# Verify API access
curl -k -H "Authorization: PVEAPIToken=$PM_API_TOKEN_ID=$PM_API_TOKEN_SECRET" \
  "$PM_API_URL/version"
```

### State lock issues
```bash
# Force unlock (use with caution)
terraform force-unlock <lock_id>
```

### Provider version conflicts
```bash
# Update provider versions
terraform init -upgrade
```

## Resources

- [Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Terraform Cloudflare Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [Cloudflare R2 Backend](https://developer.cloudflare.com/r2/examples/terraform/)
- [yamisskey-ansible](https://github.com/yamisskey-dev/yamisskey-ansible)
- [yamisskey-host](https://github.com/yamisskey-dev/yamisskey-host)

## Contributing

1. Create feature branch
2. Run `terraform fmt` and `terraform validate`
3. Test with `terraform plan`
4. Submit pull request with clear description

## License

MIT License - See [LICENSE](LICENSE) file for details

## Related Projects

- [yamisskey-ansible](https://github.com/yamisskey-dev/yamisskey-ansible) - Server configuration management
- [yamisskey-host](https://github.com/yamisskey-dev/yamisskey-host) - Infrastructure documentation
- [yamisskey](https://github.com/yamisskey-dev/yamisskey) - Misskey instance
