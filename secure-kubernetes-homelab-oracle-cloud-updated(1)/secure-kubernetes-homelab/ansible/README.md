# Ansible Automation — Ubuntu SSH Authentication Hardening

**Recorded:** November 20, 2026  
**Scope:** Existing OCI-hosted Ubuntu webserver, managed from an Ubuntu laptop over Tailscale.  
**Milestone:** First Ansible-managed SSH configuration update and successful post-change remote login.

## Purpose

Convert the SSH settings previously configured by hand into a repeatable Ansible playbook. Ansible runs from the Ubuntu laptop (control node) and connects to the managed Ubuntu server using the existing Tailscale network and SSH key authentication. No Ansible agent or new inbound port is required on the server.

This playbook concerns **OpenSSH authentication**, not changes to Kubernetes, Traefik, NGINX, or OCI networking.

## Files

- [`playbooks/harden-ssh.yml`](playbooks/harden-ssh.yml) — working playbook implementing the four observed SSH controls.
- [`inventory.example.ini`](inventory.example.ini) — redacted inventory *template*, not the actual device inventory.
- [`.gitignore`](.gitignore) — excludes private inventory and typical key files when this directory is used as a local Ansible project.

## Configuration enforced

The playbook maintains `/etc/ssh/sshd_config.d/00-disable-root-login.conf` with the following values:

```sshconfig
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
```

| Setting | Purpose |
| --- | --- |
| `PermitRootLogin no` | Prevent direct root SSH authentication |
| `PasswordAuthentication no` | Disallow password-based SSH authentication |
| `KbdInteractiveAuthentication no` | Disallow keyboard-interactive authentication |
| `PubkeyAuthentication yes` | Allow SSH public-key authentication |

The managed file is owned by `root:root` with mode `0644`. The Ansible `copy` task specifies `backup: true` and notifies two handlers on a change: first `sshd -t` to check syntax, then a reload of the Ubuntu `ssh` service. Ansible does not continuously monitor for drift; the playbook enforces the declared configuration when executed.

**Operational caution:** The syntax-check handler runs *after* the file is written but *before* the service reload. An invalid file may therefore remain on disk if validation fails. Preserve an existing SSH session and use the backup for recovery where needed. This playbook represents the working implementation used in the lab, not an exhaustive OpenSSH hardening role.

## Reproduce from an Ubuntu Ansible control node

Install Ansible using your preferred supported method, then copy the template to a local inventory file and replace the placeholders with your own Tailscale address and SSH key path:

```bash
cd ansible
cp inventory.example.ini inventory.ini
# Edit inventory.ini locally (never publish it).

ansible-inventory -i inventory.ini --graph
ansible webservers -i inventory.ini -m ansible.builtin.ping

# Optionally inspect playbook structure:
ansible-playbook -i inventory.ini playbooks/harden-ssh.yml --syntax-check

# Enforce the baseline:
ansible-playbook -i inventory.ini playbooks/harden-ssh.yml
```

If the remote `sudo` configuration requires a password, append `--ask-become-pass` to the playbook command.

## Observed deployment evidence

The user-provided terminal captures show:

1. Ansible was installed successfully on the Ubuntu laptop; `ansible --version` reported **ansible-core 2.20.1**.
2. The INI inventory was parsed, identifying the `webservers` group and one managed server.
3. `ansible.builtin.ping` via that inventory returned `SUCCESS`, `changed: false`, and `ping: pong` from the managed server.
4. An initial run of the root-login-only playbook returned `ok=1 changed=0 failed=0`, demonstrating no change when the managed file already matched.
5. After expanding the playbook to manage all four SSH authentication settings, the task reported **changed**, the `sshd -t` validation handler reported **ok**, and the SSH reload handler reported **changed**.
6. The final play recap reported:

```text
PLAY RECAP
<MANAGED_SERVER> : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

7. A **new SSH session** from the Ubuntu laptop successfully reached the Ubuntu server after the Ansible deployment. The screenshot shows the Ubuntu welcome banner and interactive server prompt.

The evidence establishes a successful playbook deployment and preserved non-root SSH access. It **does not** by itself show a second run of the final four-setting playbook with `changed=0`, nor a fresh `sshd -T` output captured after that final run.

### Sensitive data handling

The source screenshots contain terminal identities, the private-key filename, device aliases and Tailscale IP addresses. The public documentation therefore uses a sanitized transcript and a placeholder inventory instead of reproducing those identifiers. **No private key, actual inventory, or credential is committed.**

## Relation to prior work

- [Manual SSH root-login hardening](../docs/05-security/ubuntu-ssh-hardening.md)
- [Tailscale access-control hardening](../docs/01-tailscale/access-control-hardening.md)

These earlier controls remain relevant; Ansible now provides the repeatable enforcement mechanism for SSH authentication settings.
