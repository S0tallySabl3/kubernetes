# Ubuntu SSH Hardening — Disable Direct Root Login

**Recorded:** November 17, 2026  
**System:** Ubuntu 26.04.1 LTS on the OCI-hosted Kubernetes server  
**Control:** OpenSSH server authentication — `PermitRootLogin`

## Purpose and scope

This milestone tightens host-level authentication after network access was restricted with Tailscale. Only the Ubuntu OpenSSH configuration was changed. Administrative users continue authenticating with SSH keys using the normal non-root account.

## Baseline inspection

The effective SSH server settings were inspected with a read-only command:

```bash
sudo sshd -T | grep -E '^(passwordauthentication|kbdinteractiveauthentication|permitrootlogin|pubkeyauthentication) '
```

Observed before the change:

```text
permitrootlogin prohibit-password
pubkeyauthentication yes
passwordauthentication no
kbdinteractiveauthentication no
```

The `prohibit-password` setting prevents password authentication for root but still permits direct root login with a qualifying SSH key. A search for active `PermitRootLogin` and `Match` directives in `/etc/ssh/sshd_config` and `/etc/ssh/sshd_config.d/` returned no matches; the observed initial value was consistent with the OpenSSH default.

## Implemented configuration

Created a dedicated OpenSSH configuration drop-in:

```text
/etc/ssh/sshd_config.d/00-disable-root-login.conf
```

File content:

```sshconfig
PermitRootLogin no
```

The operator reported validating and applying the change, including restarting the SSH service. The exact service-management output was not captured in the submitted screenshots.

## Verification

The effective post-change configuration was shown in the supplied terminal capture:

```bash
sudo sshd -T | grep "permitrootlogin"
```

```text
permitrootlogin no
```

A subsequent fresh SSH login as the non-root Ubuntu administration account succeeded with a private-key identity from a separate Linux client. The supplied session also showed a clean logout.

| Acceptance check | Evidence | Result |
| --- | --- | --- |
| Direct root SSH login disabled | `sshd -T` returned `permitrootlogin no` | Passed — effective configuration |
| Non-root SSH administrative access preserved | Fresh remote SSH login displayed Ubuntu welcome banner and interactive shell; logout completed | Passed |
| Password and keyboard-interactive authentication | Initial `sshd -T` output showed both disabled | Observed at baseline; not separately retested after change |
| OpenSSH syntax validation | Operator reported applying the SSH change; no `sshd -t` output submitted | Not independently evidenced |

The screenshots demonstrate the configured setting and successful non-root connectivity; a direct root-authentication attempt was not performed.

### Redacted screenshot evidence

![Effective root-login setting, redacted](../../screenshots/07-ubuntu-ssh/01-effective-root-login-redacted.png)

The supplied successful SSH re-login screenshot was also sanitized locally. For the public repository, the result is transcribed above without publishing its host addresses, user identities, or private-key filename.

## Security rationale

Disabling root SSH login reduces direct privileged authentication paths. Administrators continue to use a named non-root account and elevate privileges through `sudo` when necessary. This reinforces the Tailscale network-level controls without changing Kubernetes, Traefik, NGINX, or OCI routing.

**Outcome:** OpenSSH reports `PermitRootLogin no`, and a new non-root SSH session succeeded after the change.

## Automation follow-up (November 20, 2026)

The Ubuntu SSH authentication settings were later managed using an [Ansible playbook](../../ansible/README.md) rather than only manual changes. The playbook also covers password, keyboard-interactive, and public-key authentication settings and was applied successfully with a subsequent SSH login.
