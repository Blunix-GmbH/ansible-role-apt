import os
import testinfra.utils.ansible_runner

inventory = os.environ.get("MOLECULE_INVENTORY_FILE", "inventory/hosts")
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(inventory).get_hosts("all")


def test_haveged_config(host):
    f = host.file("/etc/default/haveged")
    assert f.exists
    assert f.user == "root"
    assert f.group == "root"
    assert f.mode == 0o640
    assert 'DAEMON_ARGS="-w 3072"' in f.content_string
