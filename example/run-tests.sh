#!/usr/bin/env bash
#
# Provision a disposable Debian test host in IONOS Cloud via Terraform,
# write its IP into example/inventory/hosts, run the example play and then pytest tests.

set -euo pipefail


# Check commands
require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }
}
require_cmd terraform
require_cmd ansible-playbook
! test -f ~/.virtualenvs/ansible-role-dev/bin/activate && python3 -m venv .virtualenvs/
source ~/.virtualenvs/ansible-role-dev/bin/activate
which pytest || pip3 install pytest testinfra

# Pass through ionosctl token envs into Terraform variables if present
export TF_VAR_ionosctl_token_value="${IONOSCTL_TOKEN_VALUE:-${IONOSCTL_TOKEN:-${IONOS_TOKEN:-}}}"


# Make sure this script runs from the example/ directory
current_dir=$(basename $(pwd))
if [[ "$current_dir" != "example" ]]; then
    echo "You are not executing $0 from inside the role/example/ directory - cd to example/ and try again!"
    exit 1
fi


# Parse argument
arg1=${1:-}
if [[ "$arg1" == "-d" ]]; then
    echo "Destroying terraform..."
    terraform destroy -input=false -auto-approve
    exit $?
fi


# Create instances with terraform
echo "Applying Terraform..."
terraform init -input=false -upgrade
terraform apply -input=false -auto-approve
IP="$(terraform output -raw public_ip)"
if [[ -z "${IP}" ]]; then
  echo "Failed to obtain public IP from terraform output" >&2
  exit 1
fi

# Cleanup previous ssh connections
ssh-keygen -R "cus-dev-prod-web-1"
ssh-keygen -R $IP
# First connect to auto-accept
ssh root@"$IP" -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o ConnectionAttempts=6 /bin/true


# Run ansible playbook
echo "Running ansible-playbook..."
# Pin ansible_python_interpreter in inventory if you want to silence interpreter discovery warnings.
ANSIBLE_ROLES_PATH="../.." ansible-playbook -i inventory/hosts \
    -e 'ansible_cake_managed=Managed by Ansible from {{ template_fullpath }}' \
    play.yml
# Makes it crash with:
#TASK [ansible-role-apache2 : install apache2] *****************************************************************************************************************************************************************
#[ERROR]: A worker was found in a dead state
#    -e 'ansible_ssh_common_args=-o ConnectTimeout=10 -o ConnectionAttempts=6' \

# Run tests
echo "Running tests..."
ls tests/*py | while read testfile; do
    ansible_host=$(grep -m1 ansible_host inventory/hosts | sed 's/.*ansible_host=\([^ ]*\).*/\1/')
    MOLECULE_INVENTORY_FILE=inventory/hosts ~/.virtualenvs/ansible-role-dev/bin/pytest --hosts=ssh://root@$ansible_host $testfile
done

# Print how to destroy ionos servers
echo -e "Done. To destroy the resources:\n$0 -d"
