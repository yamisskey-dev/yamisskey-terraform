# Setup Guide

## Prerequisites

### Proxmox Host

```bash
ssh root@192.168.1.1
hostname  # Should return 'mary'
```

### Network Bridges

```bash
cat >> /etc/network/interfaces << 'EOF'

auto vmbr1
iface vmbr1 inet manual
        bridge-ports none
        bridge-stp off
        bridge-fd 0

auto vmbr2
iface vmbr2 inet manual
        bridge-ports none
        bridge-stp off
        bridge-fd 0
EOF

ifreload -a
```

### API Token

```bash
pveum user token add root@pam terraform-token --privsep 0
# Save the secret
```

## Templates

### Ubuntu 24.04 (ID: 9000)

```bash
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img

qm create 9000 --name ubuntu-24.04-cloudinit --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 ubuntu-24.04-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000
```

### Debian 12 (ID: 9001) - For T-Pot

```bash
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

qm create 9001 --name debian-12-cloudinit --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9001 debian-12-generic-amd64.qcow2 local-lvm
qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9001-disk-0
qm set 9001 --boot c --bootdisk scsi0
qm set 9001 --ide2 local-lvm:cloudinit
qm set 9001 --serial0 socket --vga serial0
qm set 9001 --agent enabled=1
qm template 9001
```

### OPNsense ISO

```bash
cd /var/lib/vz/template/iso
wget https://mirror.ams1.nl.leaseweb.net/opnsense/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2
bunzip2 OPNsense-25.1-dvd-amd64.iso.bz2
```

## Secrets (SOPS + age)

```bash
# Ensure age key exists (same as yamisskey-ansible)
ls ~/.config/sops/age/keys.txt
# Or symlink
ln -sf ~/.sops/key.txt ~/.config/sops/age/keys.txt

# Edit secrets
sops secrets.sops.yaml
```

Required secrets:
- `proxmox_api_url`: `https://192.168.1.1:8006/api2/json`
- `proxmox_api_token_id`: `root@pam!terraform-token`
- `proxmox_api_token_secret`: (your token)
- `proxmox_tls_insecure`: `true`

## Deploy

```bash
terraform init
terraform plan
terraform apply -var="opnsense_enabled=true" -var="test_vm_enabled=false"
```

## OPNsense Installation

1. Open Proxmox console for VM 101
2. Boot from ISO
3. Login: `installer` / `opnsense`
4. Follow installation wizard
5. Configure interfaces:
   - vtnet0 → WAN (DHCP or 192.168.1.x)
   - vtnet1 → LAN (10.0.1.1/24) - OpenClaw isolated segment
   - vtnet2 → DMZ (10.0.2.1/24)
6. Access Web GUI: `https://<WAN_IP>`
7. Default login: `root` / `opnsense`

## Troubleshooting

### VM clone timeout
QEMU guest agent not responding. Cloud-init images may not include it.

### "bridge does not exist"
```bash
cat /etc/network/interfaces  # Verify vmbr0/1/2 exist
ifreload -a
```

### "hostname lookup failed"
```bash
hostname  # Verify matches proxmox_node variable (mary)
```

### API connection
```bash
curl -k -H "Authorization: PVEAPIToken=root@pam!terraform-token=SECRET" \
  "https://192.168.1.1:8006/api2/json/version"
```
