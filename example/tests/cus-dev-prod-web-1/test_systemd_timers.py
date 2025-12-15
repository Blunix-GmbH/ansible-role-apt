import os
import pytest
import testinfra.utils.ansible_runner

inv = os.environ.get("MOLECULE_INVENTORY_FILE", "inventory/hosts")
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(inv).get_hosts('all')


@pytest.mark.parametrize('svc', [
    'apt-daily.timer',
    'apt-daily-upgrade.timer'
])
def test_svc(host, svc):
    service = host.service(svc)

    assert service.is_running
    assert service.is_enabled
