# homelab

k3s on a Raspberry Pi 4, bootstrapped with Ansible and managed via Flux GitOps.

## Quickstart

```bash
# 1. Install prerequisites (brew)
make setup

# 2. Bootstrap Pi with k3s
export TAILSCALE_AUTH_KEY=tskey-auth-xxxxx
make ansible

# 3. Bootstrap Flux
export GITHUB_TOKEN=ghp_xxx
export GITHUB_USER=bradschwartz
make flux

# 4. Expose a service via Tailscale:
#    Add to your app's Deployment:
#      tailscale.com/expose: "true"
#    The operator gives it a tailnet IP automatically.
```

## Structure

```
pi/                 # Pi boot config (flash this onto SD card)
  user-data         #   cloud-init: hostname, users, passwordless sudo
ansible/            # Ansible playbooks for Pi provisioning
  site.yml          #   Main playbook
  roles/
    bootstrap/      #   OS hardening, packages, kernel config
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

## Exposing Services via Tailscale

The cluster has the [tailscale-operator](https://tailscale.com/kb/1236/kubernetes-operator) installed. To expose any service on your tailnet, add the annotation to its metadata:

```yaml
metadata:
  annotations:
    tailscale.com/expose: "true"
```

The operator creates a Tailscale node for that service. Access it via `http://service-name` (MagicDNS) or the Tailscale IP from the admin console.

## Environment Variables

See `.env.example` — or set `PI_HOST`, `PI_USER`, `TAILSCALE_AUTH_KEY`, `GITHUB_TOKEN`, `GITHUB_USER` directly.
