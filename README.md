# yamisskey-terraform

Proxmox VE VM provisioning for yamisskey security research infrastructure.

## VMs

| VM | ID | Spec | Network | Purpose | Status |
|----|-----|------|---------|---------|--------|
| OPNsense | 101 | 4c/8GB/32GB | vmbr0,1,2 | Router/Firewall | Active |
| T-Pot | 100 | 8c/16GB/256GB | vmbr2 | Honeypot (ELK) | Active |
| Malcolm | 102 | 12c/24GB/500GB | vmbr2 | Traffic analysis | Active |
| CTFd | - | 4c/4GB/100GB | vmbr2 | CTF platform | Planned |
| GOAD | - | 4c/20GB/80GB | vmbr1 | AD pentest lab | Planned |

## Network

| Bridge | Subnet | Purpose |
|--------|--------|---------|
| vmbr0 | 192.168.1.0/24 | WAN/Management |
| vmbr1 | 10.0.1.0/24 | LAN |
| vmbr2 | 10.0.2.0/24 | DMZ (isolated) |

## Hosting

```mermaid
graph TB
    classDef host fill:#e2e8f0,stroke:#334155,stroke-width:2px
    classDef net fill:#fff3e0,stroke:#ef6c00
    classDef sec fill:#fee2e2,stroke:#991b1b
    classDef mon fill:#d1fae5,stroke:#047857
    classDef ctf fill:#fef3c7,stroke:#d97706

    subgraph proxmox[GMKtec K10 - Proxmox VE]
        direction TB

        subgraph networks[Virtual Networks]
            vmbr0[vmbr0 WAN<br/>192.168.1.0/24]:::net
            vmbr1[vmbr1 LAN<br/>10.0.1.0/24]:::net
            vmbr2[vmbr2 DMZ<br/>10.0.2.0/24]:::net
        end

        subgraph vms[Virtual Machines]
            opnsense[OPNsense<br/>4c/8GB]:::sec
            tpot[T-Pot Hive<br/>8c/16GB<br/>Cowrie/Dionaea/ELK]:::sec
            malcolm[Malcolm<br/>12c/24GB<br/>Zeek/Suricata/Arkime]:::mon
            ctfd[CTFd<br/>4c/4GB<br/>Docker]:::ctf
            goad[GOAD Light<br/>4c/20GB<br/>AD攻撃練習]:::ctf
        end
    end

    vmbr0 --> opnsense
    opnsense --> vmbr1 & vmbr2
    vmbr1 --> goad
    vmbr2 --> tpot & malcolm & ctfd

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

### GOAD (Game Of Active Directory)

AD攻撃練習環境。GOAD-Lightを予定（メモリ20GB、ディスク80GB）。

- https://orange-cyberdefense.github.io/GOAD/
- Proxmoxプロバイダ対応

### CTFd

CTFプラットフォーム。スコアボード + 問題管理 + Docker隔離。

- https://github.com/CTFd/CTFd

## Docs

- [Setup Guide](docs/setup.md) - Detailed setup instructions

