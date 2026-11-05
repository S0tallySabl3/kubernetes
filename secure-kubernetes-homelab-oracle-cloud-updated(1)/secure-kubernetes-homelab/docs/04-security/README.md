# Phase 04 — Security Hardening (planned)

SSH login is confirmed, but **least-privilege ingress and OS hardening are not verified yet**.

## Checklist

- [ ] Inspect all OCI security lists and NSGs affecting the VM's VNIC.
- [ ] Restrict TCP/22 ingress to a verified administrator public IP `/32` (or a managed private access path), keeping an existing SSH session open.
- [ ] Test a fresh SSH session before removing any previous access rule.
- [ ] Confirm `sshd` is listening only where intended and public-key auth works.
- [ ] Review guest firewall, login policy, automatic updates and security patches.
- [ ] Document SSH host-key verification and safe key storage (never commit private keys).
- [ ] Decide whether to deploy Tailscale on OCI and eliminate public administrative access in a later migration.
- [ ] Review Kubernetes API exposure, RBAC, secrets, network policies and container image provenance after cluster deployment.

## Why this matters

A route table points packets to their next hop. It **does not enforce** who can connect to port 22. OCI ingress rules, host firewall policy and SSH authentication provide separate enforcement layers. Successful login does not prove these layers are configured with least privilege.
