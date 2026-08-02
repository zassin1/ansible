#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform"
ANSIBLE_DIR="$ROOT_DIR/ansible"
SUBSCRIPTION_ID="c376c5da-f553-433b-8db3-72b61be70105"
TENANT_ID="d5783933-d8d3-4c23-8256-4662298b20e9"
SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY:-$HOME/.ssh/id_ed25519}"
SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-${SSH_PRIVATE_KEY}.pub}"

for command in az terraform ansible-playbook ssh-keygen; do
  command -v "$command" >/dev/null || { echo "Missing required command: $command" >&2; exit 1; }
done

if [[ ! -f "$SSH_PUBLIC_KEY" ]]; then
  echo "Creating an Ed25519 SSH key at $SSH_PRIVATE_KEY"
  mkdir -p "$(dirname "$SSH_PRIVATE_KEY")"
  ssh-keygen -t ed25519 -f "$SSH_PRIVATE_KEY" -N "" -C "ansible-blog-azure"
fi

if ! az account show >/dev/null 2>&1; then
  az login --tenant "$TENANT_ID"
fi
az account set --subscription "$SUBSCRIPTION_ID"

terraform -chdir="$TF_DIR" init
terraform -chdir="$TF_DIR" apply -auto-approve -var="subscription_id=$SUBSCRIPTION_ID" -var="tenant_id=$TENANT_ID" -var="ssh_public_key_path=$SSH_PUBLIC_KEY"

SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" "$ROOT_DIR/scripts/generate_inventory.sh"
public_ip="$(terraform -chdir="$TF_DIR" output -raw public_ip_address)"
admin_user="$(terraform -chdir="$TF_DIR" output -raw admin_username)"

echo "Waiting for SSH on ${admin_user}@${public_ip}..."
for attempt in $(seq 1 30); do
  if ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${admin_user}@${public_ip}" true 2>/dev/null; then break; fi
  if [[ "$attempt" -eq 30 ]]; then echo "SSH did not become ready in time." >&2; exit 1; fi
  sleep 10
done

(cd "$ANSIBLE_DIR" && ansible-playbook playbooks/deploy.yml)
website_url="$(terraform -chdir="$TF_DIR" output -raw website_url)"
echo "Deployment complete: $website_url"
