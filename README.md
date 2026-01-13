# yamisskey-terraform

Proxmox VE VM provisioning for yamisskey security research infrastructure.

**Host:** GMKtec K10 (64GB RAM / 12C24T)

## VMs

| VM | ID | Spec | Network | Purpose | Status |
|----|-----|------|---------|---------|--------|
| OPNsense | 101 | 4c/8GB/32GB | vmbr0,1,2 | Router/Firewall | Active |
| T-Pot | 100 | 8c/16GB/256GB | vmbr2 | Honeypot (ELK) | Active |
| CTFd | 103 | 2c/4GB/40GB | vmbr2 | CTF platform | Planned |
| GOAD-Light | - | 4c/24GB/120GB | vmbr1 | AD pentest lab | Planned |

### Resource Profiles (64GB Host)

| Profile | VMs | Memory | Notes |
|---------|-----|--------|-------|
| **Always-on** | OPNsense + T-Pot | 24GB | 常時稼働（攻撃収集） |
| CTF | + CTFd | +4GB (28GB) | イベント時 |
| AD Lab | OPNsense + GOAD-Light | 32GB | T-Pot停止して使用 |

**Reserved:** Proxmox VE ~4GB

## Network

| Bridge | Subnet | Purpose |
|--------|--------|---------|
| vmbr0 | 192.168.1.0/24 | WAN/Management |
| vmbr1 | 10.0.1.0/24 | LAN |
| vmbr2 | 10.0.2.0/24 | DMZ (isolated) |

## Architecture

```mermaid
graph TB
    classDef host fill:#e2e8f0,stroke:#334155,stroke-width:2px
    classDef net fill:#fff3e0,stroke:#ef6c00
    classDef sec fill:#fee2e2,stroke:#991b1b
    classDef ctf fill:#fef3c7,stroke:#d97706
    classDef planned fill:#f3f4f6,stroke:#6b7280,stroke-dasharray: 5 5

    subgraph proxmox["GMKtec K10 - Proxmox VE (64GB)"]
        direction TB

        subgraph networks[Virtual Networks]
            vmbr0[vmbr0 WAN<br/>192.168.1.0/24]:::net
            vmbr1[vmbr1 LAN<br/>10.0.1.0/24]:::net
            vmbr2[vmbr2 DMZ<br/>10.0.2.0/24]:::net
        end

        subgraph always["Always-on (24GB)"]
            opnsense[OPNsense<br/>4c/8GB]:::sec
            tpot[T-Pot Standard<br/>8c/16GB]:::sec
        end

        subgraph planned["Planned"]
            ctfd[CTFd<br/>2c/4GB]:::planned
            goad[GOAD-Light<br/>4c/24GB]:::planned
        end
    end

    vmbr0 --> opnsense
    opnsense --> vmbr1 & vmbr2
    vmbr1 -.-> goad
    vmbr2 --> tpot
    vmbr2 -.-> ctfd

    class proxmox host
```

## Setup

```bash
# 1. Configure secrets (SOPS + age)
sops secrets.sops.yaml

# 2. Deploy
terraform init
terraform apply -var="opnsense_enabled=true"
```

## Templates (on Proxmox)

```bash
# Ubuntu 24.04 (ID: 9000)
qm create 9000 --name ubuntu-24.04-cloudinit --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 ubuntu-24.04-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0 --boot c --bootdisk scsi0
qm set 9000 --ide2 local-lvm:cloudinit --serial0 socket --vga serial0 --agent enabled=1
qm template 9000

# OPNsense ISO
wget https://mirror.ams1.nl.leaseweb.net/opnsense/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2
bunzip2 OPNsense-25.1-dvd-amd64.iso.bz2
```

## Planned

### CTFd

CTFプラットフォーム。Docker Compose + Cloudflared + Nginx + Tailscale。

- https://github.com/CTFd/CTFd

### GOAD-Light

AD攻撃練習環境（3 Windows VMs）。T-Pot停止して使用。要件: 4c/20GB+/115GB+。

- https://orange-cyberdefense.github.io/GOAD/

## Docs

- [Setup Guide](docs/setup.md) - Detailed setup instructions

