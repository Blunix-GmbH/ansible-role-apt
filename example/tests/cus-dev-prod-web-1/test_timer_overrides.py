import os
import testinfra.utils.ansible_runner

inventory = os.environ.get("MOLECULE_INVENTORY_FILE", "inventory/hosts")
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(inventory).get_hosts("all")


def _check_override(host, path, snippets):
    f = host.file(path)
    assert f.exists
    assert f.user == "root"
    assert f.group == "root"
    assert f.mode == 0o644
    content = f.content_string
    for s in snippets:
        assert s in content


def test_apt_daily_timer_override(host):
    _check_override(
        host,
        "/etc/systemd/system/apt-daily.timer.d/override.conf",
        ["OnCalendar=hourly", "RandomizedDelaySec=0"],
    )


def test_apt_daily_upgrade_timer_override(host):
    _check_override(
        host,
        "/etc/systemd/system/apt-daily-upgrade.timer.d/override.conf",
        ["OnCalendar=*-*-* *:15:00", "RandomizedDelaySec=0"],
    )
