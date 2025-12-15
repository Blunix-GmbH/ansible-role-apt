import os
import testinfra.utils.ansible_runner

inventory = os.environ.get("MOLECULE_INVENTORY_FILE", "inventory/hosts")
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(inventory).get_hosts("all")


def test_base_packages_installed(host):
    for pkg in ["unattended-upgrades", "haveged", "curl", "vim", "gnupg2"]:
        assert host.package(pkg).is_installed

