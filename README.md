# APT Ansible Role (ansible-role-apt) from Blunix GmbH

This Ansible role configures APT on Debian servers, installs a curated base package set, and tunes unattended upgrades plus systemd timers for regular updates—exactly as we use it in production.

The Ansible Role is written and actively maintained by <a href="https://www.blunix.com" target="_blank">Blunix GmbH</a>.
It is used in the Blunix <a href="https://www.blunix.com/linux-managed-hosting.html" target="_blank">Linux Managed Hosting</a> Stack.
Its usage is documented at our <a href="https://www.blunix.com/manual" target="_blank">Linux Managed Hosting Documentation</a>.


## Features

- Installs a configurable base set of useful packages for Debian servers (editors, networking tools, Python tooling, etc.).
- Enables unattended upgrades via `debconf`.
- Configures systemd `apt-daily` and `apt-daily-upgrade` timers to run hourly.
- Tunes `haveged` when installed via this role.
- Runs `apt-get autoremove` to clean up unused packages.


## Requirements

- Ansible: **>= 2.20.0**
- Managed operating systems:
  - Debian **trixie**



## Role variables, inventory and example playbook

Production playbooks apply the role without overrides; if you want to customize base packages, use the inventory example below. The full example lives under `example/`:

- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/example/inventory/group_vars/all/apt.yml" target="_blank">`example/inventory/group_vars/all/apt.yml`</a> — optional `apt_default_packages` override.
- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/example/play.yml" target="_blank">`example/play.yml`</a> — minimal play applying the role to all hosts.

The defaults cover the base package set, unattended upgrades via debconf and systemd timer overrides for the unattended-upgrades frequency.


## Managed files and templates

- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/tasks/main.yml#L54-L73" target="_blank"><code>/etc/apt/apt.conf.d/50unattended-upgrades</code></a> — enforces security updates on all hosts, optionally enables non-security upgrades (`apt_unattended_apt_version_upgrades`), and can trigger an automatic reboot after kernel updates (`apt_unattended_reboot`, `apt_unattended_reboot_time`).
- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/tasks/main.yml#L24-L33" target="_blank"><code>/etc/systemd/system/apt-daily.timer.d/override.conf</code></a> (runs hourly).
- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/tasks/main.yml#L36-L46" target="_blank"><code>/etc/systemd/system/apt-daily-upgrade.timer.d/override.conf</code></a> (runs hourly, offset at `:15`).
- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/tasks/main.yml#L75-L82" target="_blank"><code>/etc/default/haveged</code></a> (only when `haveged` is in `apt_default_packages`).



### Infrastructure As Code Tests

- Provision: use <a href="https://github.com/Blunix-GmbH/ansible-roles/blob/main/dev-tools/main.tf" target="_blank"><code>dev-tools/main.tf</code></a> with the apt role enabled to create a test host.
- Playbook: <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/example/play.yml" target="_blank"><code>example/play.yml</code></a> applies the role, seeds the timer overrides, and configures unattended-upgrades.
- Tests in `example/tests/`:
  - <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/example/tests/cus-dev-prod-web-1/test_systemd_timers.py" target="_blank"><code>cus-dev-prod-web-1/test_systemd_timers.py</code></a>: verifies the apt-daily/apt-daily-upgrade timer overrides are installed and enabled.

## Author Information

Blunix GmbH Berlin  

`root@Linux:~# Support | Consulting | Hosting | Training`

Blunix GmbH provides 24/7/365 Linux emergency support and consulting, Service Level Agreements for Debian Linux managed hosting using Ansible Configuration Management as well as Linux trainings and workshops.

Learn more at <a href="https://www.blunix.com" target="_blank">https://www.blunix.com</a>.

## Contact Information

Click here to see our <a href="https://www.blunix.com/#contact" target="_blank">Contact Information</a>.

For bug reports and feature requests, please open an issue in this repository’s GitHub issue tracker.


## License

Apache-2.0

Please refer to the `LICENSE` file in the root of this repository.
