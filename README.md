# APT Ansible Role (ansible-role-apt) from Blunix GmbH

This Ansible role configures APT on Debian servers, installs a curated base package set, and tunes unattended upgrades plus systemd timers for regular updates—exactly as we use it in production.

The Ansible Role is written and actively maintained by <a href="https://www.blunix.com" target="_blank">Blunix GmbH</a>.
It is used in the Blunix <a href="https://www.blunix.com/linux-managed-hosting.html" target="_blank">Linux Managed Hosting</a> Stack.
Its usage is documented at our <a href="https://www.blunix.com/manual" target="_blank">Linux Managed Hosting Documentation</a>.

---

## Features

- Installs a configurable base set of useful packages for Debian servers (editors, networking tools, Python tooling, etc.).
- Enables unattended upgrades via `debconf`.
- Configures systemd `apt-daily` and `apt-daily-upgrade` timers to run hourly.
- Tunes `haveged` when installed via this role.
- Runs `apt-get autoremove` to clean up unused packages.

---

## Requirements

- Ansible: **>= 2.9.10**
- Managed operating systems:
  - Debian **trixie**

---


## Role variables, inventory and example playbook

Production playbooks apply the role without overrides; if you want to customize base packages, use the inventory example below. The full example lives under `example/`:

- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/example/inventory/group_vars/all/apt.yml" target="_blank">`example/inventory/group_vars/all/apt.yml`</a> — optional `apt_default_packages` override.
- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/example/play.yml" target="_blank">`example/play.yml`</a> — minimal play applying the role to all hosts.

The defaults cover the base package set, unattended upgrades via debconf and systemd timer overrides for the unattended-upgrades frequency.

---

## Managed files and templates

- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/tasks/main.yml" target="_blank"><code>/etc/systemd/system/apt-daily.timer.d/override.conf</code></a> (four runs per day).
- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/tasks/main.yml" target="_blank"><code>/etc/systemd/system/apt-daily-upgrade.timer.d/override.conf</code></a> (four runs per day, offset from `apt-daily`).
- <a href="https://github.com/Blunix-GmbH/ansible-role-apt/blob/main/tasks/main.yml" target="_blank"><code>/etc/default/haveged</code></a> (only when `haveged` is in `apt_default_packages`).

---

## Author Information

Blunix GmbH Berlin  

`root@Linux:~# Support | Consulting | Hosting | Training`

Blunix GmbH provides 24/7/365 Linux emergency support and consulting, Service Level Agreements for Debian Linux managed hosting using Ansible Configuration Management as well as Linux trainings and workshops.

Learn more at <a href="https://www.blunix.com" target="_blank">https://www.blunix.com</a>.

## Contact Information

Click here to see our <a href="https://www.blunix.com/#contact" target="_blank">Contact Information</a>.

For bug reports and feature requests, please open an issue in this repository’s GitHub issue tracker.

---

## License

Apache-2.0

Please refer to the `LICENSE` file in the root of this repository.

### Tests

The directory `test/` contains an example `play.yml` as well as `inventory/group_vars/`, if applicable to the role. the script `example/run-tests.sh` creates a IONOS cloud instance with terraform, uses the example inventory and playbook to run the role and then run pytest tests located in `example/tests/`. Destroy the terraform using `./run-tests.sh -d`.
