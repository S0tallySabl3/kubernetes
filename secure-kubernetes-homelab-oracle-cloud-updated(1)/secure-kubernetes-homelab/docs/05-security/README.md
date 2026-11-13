# Phase 05 — Security Hardening (planned)

SSH login is confirmed, but **least-privilege ingress and OS hardening are not verified yet**.

## Checklist

- [ ] Inspect all OCI security lists and NSGs affecting the VM's VNIC.
- [ ] Restrict TCP/22 ingress to a verified administrator public IP `/32` (or a managed private access path), keeping an existing SSH session open.
- [ ] Test a fresh SSH session before removing any previous access rule.
- [ ] Confirm `sshd` is listening only where intended and public-key auth works.
- [ ] Review guest firewall, login policy, automatic updates and security patches.
- [ ] Document SSH host-key verification and safe key storage (never commit private keys).
- [x] Establish Tailscale private administration access to OCI (verified in prior phases).
- [x] Generate Tailscale TLS certificate for the existing hostname and verify key files are root-owned and mode `600` (2026-11-11).
- [x] Create the Kubernetes TLS Secret and configure Traefik HTTPS termination; verify browser HTTPS from a separate Windows Tailscale client (Phase 6).
- [ ] Review and secure the Kubernetes Secret lifecycle, access control and datastore encryption.
- [ ] Establish certificate and TLS Secret renewal before 2027-02-09.
- [ ] Review Kubernetes API exposure, RBAC, secrets, network policies and container image provenance after cluster deployment.

## Why this matters

A route table points packets to their next hop. It **does not enforce** who can connect to port 22. OCI ingress rules, host firewall policy and SSH authentication provide separate enforcement layers. Successful login does not prove these layers are configured with least privilege.

See [Phase 6 deployment and verification](../06-https-tls/README.md). Private HTTPS was demonstrated; the remaining host/network-hardening checklist is not implied complete.
