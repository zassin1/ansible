# Codex Handoff Instructions

## Goal
Maintain a course-end project that provisions one Ubuntu VM in Azure with Terraform and deploys a static blogging profile site to Nginx with Ansible.

## Fixed Azure scope
- Subscription: `c376c5da-f553-433b-8db3-72b61be70105`
- Tenant: `d5783933-d8d3-4c23-8256-4662298b20e9`

Do not add credentials, client secrets, private keys, Terraform state, or generated inventory to Git.

## Validation before committing
Run:

```bash
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
cd ansible && ansible-playbook playbooks/deploy.yml --syntax-check -i inventory/hosts.yml.example
```

## Expected workflow
1. Make changes on a feature branch.
2. Preserve idempotency in Ansible.
3. Keep Terraform resources minimal and low-cost.
4. Update README.md when behavior changes.
5. Commit with a descriptive message and open a pull request.
