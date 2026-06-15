# homelab

k3s on a Raspberry Pi 4, bootstrapped with Ansible and managed via Flux GitOps.

## Quickstart

```bash
# 1. Install prerequisites (brew)
make setup

# 2. Configure Pi for Ansible (passwordless sudo)
make setup-pi

# 3. Bootstrap Pi with k3s + Tailscale
make ansible

# 4. Bootstrap Flux (set GITHUB_TOKEN and GITHUB_USER first)
export GITHUB_TOKEN=ghp_xxx
export GITHUB_USER=your_username
make flux
```

## Structure

```
pi/                 # Pi boot config (flash this onto SD card)
  user-data         #   cloud-init: hostname, users, passwordless sudo
ansible/            # Ansible playbooks for Pi provisioning
  site.yml          #   Main playbook
  roles/
    bootstrap/      #   OS hardening, packages, kernel config
    tailscale/      #   Install and auth Tailscale
    k3s/            #   Install k3s single-node cluster
    flux/           #   Fetch kubeconfig for local use
clusters/
  raspberrypi/      # Flux manifests (source of truth)
infrastructure/     # Cluster-wide infra (ingress, cert-manager, etc.)
apps/               # Application deployments
scripts/            # Helper scripts
```

## Commands

| Command | Description |
|---|---|
| `make setup` | Install prerequisites (brew) |
| `make setup-pi` | SSH in and configure passwordless sudo |
| `make ansible` | Run Ansible to provision Pi |
| `make flux` | Bootstrap Flux into the cluster |
| `make status` | Check Pi and k3s status |
| `make clean` | Remove local kubeconfig |

## Environment Variables

See `.env.example` — or set `PI_HOST`, `PI_USER`, `GITHUB_TOKEN`, `GITHUB_USER` directly.
