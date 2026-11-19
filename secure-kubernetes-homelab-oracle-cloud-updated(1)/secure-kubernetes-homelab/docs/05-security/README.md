# Phase 05 — Foundational Security Measures

This lab demonstrates fundamental security controls supporting a Kubernetes webserver deployed in Oracle Cloud Infrastructure.

## Verified measures

- Established private SSH administration over Tailscale.
- Disabled direct root SSH login using `PermitRootLogin no`; confirmed the effective setting and successful non-root SSH access. [Ubuntu SSH hardening](ubuntu-ssh-hardening.md).
- Disabled unused `rpcbind` and its systemd socket after dependency review; confirmed TCP/UDP port 111 had no listeners. [Ubuntu rpcbind hardening](ubuntu-rpcbind-hardening.md).
- Applied a least-privilege Tailscale access grant for two authorized devices, the tagged cloud server, and TCP 22/443. [Policy change and validation](../01-tailscale/access-control-hardening.md).
- Migrated outbound connectivity to an OCI NAT Gateway and removed the initial Internet Gateway, as recorded in the network migration tests.
- Generated a certificate for the existing Tailscale hostname and verified root ownership and file permissions of `600`.
- Created a Kubernetes TLS Secret in the `webserver` namespace and configured Traefik HTTPS termination.
- Verified encrypted HTTPS and the NGINX response from a separate Windows Tailscale client.

## Security architecture

Tailscale supplies the private networking overlay. OCI networking provides the outbound path through NAT. Kubernetes Services support application discovery, and Traefik handles ingress routing and HTTPS termination.

For commands and evidence, see [Phase 6 — HTTPS/TLS deployment](../06-https-tls/README.md).
