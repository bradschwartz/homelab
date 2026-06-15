#!/usr/bin/env bash
set -euo pipefail

echo "Checking prerequisites..."

check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo "MISSING: $1 — $2"
    return 1
  else
    echo "OK: $1"
  fi
}

missing=0
check_cmd ansible "brew install ansible"  || missing=1
check_cmd kubectl "brew install kubectl"  || missing=1
check_cmd flux    "brew install fluxcd/tap/flux" || missing=1
check_cmd helm    "brew install helm"     || missing=1
check_cmd k3s     "installed via Ansible on Pi — not needed on Mac" || true

if [ "$missing" -eq 1 ]; then
  echo ""
  echo "Install missing tools with:"
  echo "  brew install ansible kubectl helm"
  echo "  brew install fluxcd/tap/flux"
  exit 1
fi

echo ""
echo "All prerequisites met!"
