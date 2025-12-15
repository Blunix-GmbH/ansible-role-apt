import os
import testinfra.utils.ansible_runner

inventory = os.environ.get("MOLECULE_INVENTORY_FILE", "inventory/hosts")
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(inventory).get_hosts("all")


def test_unattended_upgrades_file(host):
    f = host.file("/etc/apt/apt.conf.d/50unattended-upgrades")
    assert f.exists
    assert f.user == "root"
    assert f.group == "root"
    assert f.mode == 0o644
    content = f.content_string
    assert '"${distro_id}:${distro_codename}-security";' in content
    assert "origin=${distro_id},archive=${distro_codename}-security,label=Debian-Security" in content
    assert 'Unattended-Upgrade::Automatic-Reboot "true";' in content
    assert 'Unattended-Upgrade::Automatic-Reboot-Time "01:00";' in content
