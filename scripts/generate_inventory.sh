#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform"
INVENTORY="$ROOT_DIR/ansible/inventory/hosts.yml"
SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY:-$HOME/.ssh/id_ed25519}"

public_ip="$(terraform -chdir="$TF_DIR" output -raw public_ip_address)"
admin_user="$(terraform -chdir="$TF_DIR" output -raw admin_username)"

cat > "$INVENTORY" <<YAML
all:
  children:
    webservers:
      hosts:
        azure_nginx:
          ansible_host: ${public_ip}
          ansible_user: ${admin_user}
          ansible_ssh_private_key_file: ${SSH_PRIVATE_KEY}
YAML

printf 'Generated %s for %s@%s\n' "$INVENTORY" "$admin_user" "$public_ip"
