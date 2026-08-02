# Azure Nginx Blog Deployment with Terraform and Ansible

This repository solves the course-end project described in the supplied problem statement: define a remote server, install Nginx, copy a web application, deploy a templated Nginx configuration, enable the site, and execute an Ansible playbook. Terraform extends the assignment by provisioning the remote Ubuntu server in Azure first.

## Architecture

```text
Local workstation / Codex
        |
        | Terraform via Azure CLI authentication
        v
Azure Resource Group
  ├─ Virtual Network + Subnet
  ├─ Network Security Group (HTTP 80, SSH 22)
  ├─ Static Public IP
  └─ Ubuntu 22.04 Linux VM
        |
        | SSH + Ansible
        v
Nginx + static XYZ Blog website
```

## Azure configuration

The project is preconfigured for:

- Subscription ID: `c376c5da-f553-433b-8db3-72b61be70105`
- Tenant ID: `d5783933-d8d3-4c23-8256-4662298b20e9`
- Default region: `westus2`
- Default VM size: `Standard_B1s`

The IDs are identifiers, not credentials. Authentication is performed through `az login`; no password or secret is stored in the repository.

## Prerequisites

Install Azure CLI, Terraform 1.6 or later, Ansible Core, OpenSSH, and Git. Your Azure account needs permission to create resources in the configured subscription.

## Deploy everything

From Bash, WSL, Linux, or macOS:

```bash
./scripts/deploy.sh
```

The script will:

1. Create an SSH key if `~/.ssh/id_ed25519.pub` does not exist.
2. Sign in to tenant `d5783933-d8d3-4c23-8256-4662298b20e9` when needed.
3. Select subscription `c376c5da-f553-433b-8db3-72b61be70105`.
4. Run Terraform to provision the Azure VM and networking.
5. Generate the Ansible inventory from Terraform outputs.
6. Wait for SSH, run the Ansible playbook, and print the website URL.

## Restrict SSH before deployment

The example defaults to `allowed_ssh_cidr = "*"` so the lab works without knowing your public IP. For better security, create `terraform/terraform.tfvars` from the example and replace `*` with your public IPv4 address followed by `/32`:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Example:

```hcl
allowed_ssh_cidr = "198.51.100.24/32"
```

## Manual commands

```bash
az login --tenant d5783933-d8d3-4c23-8256-4662298b20e9
az account set --subscription c376c5da-f553-433b-8db3-72b61be70105

terraform -chdir=terraform init
terraform -chdir=terraform plan
terraform -chdir=terraform apply

./scripts/generate_inventory.sh
cd ansible
ansible-playbook playbooks/deploy.yml
```

## Verify

```bash
terraform -chdir=terraform output -raw website_url
curl "$(terraform -chdir=terraform output -raw website_url)"
```

Run the Ansible playbook a second time to demonstrate idempotency. The result should normally show no changes unless source files or configuration changed.

## Destroy the Azure resources

```bash
./scripts/destroy.sh
```

Azure charges can continue until the resources are destroyed.

## Repository layout

```text
terraform/                  Azure infrastructure
ansible/inventory/          Generated and example inventories
ansible/playbooks/          Deployment entry point
ansible/roles/nginx_blog/   Nginx installation and site deployment role
ansible/files/site/         Sample blogging application
scripts/                    End-to-end deployment and cleanup scripts
.github/workflows/          Terraform and Ansible validation
AGENTS.md                    Instructions for Codex
```
