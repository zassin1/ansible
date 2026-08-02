#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUBSCRIPTION_ID="c376c5da-f553-433b-8db3-72b61be70105"
TENANT_ID="d5783933-d8d3-4c23-8256-4662298b20e9"

if ! az account show >/dev/null 2>&1; then
  az login --tenant "$TENANT_ID"
fi
az account set --subscription "$SUBSCRIPTION_ID"
terraform -chdir="$ROOT_DIR/terraform" destroy -auto-approve -var="subscription_id=$SUBSCRIPTION_ID" -var="tenant_id=$TENANT_ID"
