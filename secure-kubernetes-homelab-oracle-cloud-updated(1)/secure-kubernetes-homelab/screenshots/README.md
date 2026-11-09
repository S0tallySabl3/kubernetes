# Screenshot evidence and publication status

The repository preserves the original already-committed evidence in `screenshots/01-tailscale/` and `screenshots/02-oracle-cloud/`. The November 2026 evidence collection was separately sanitized into a local archive containing **37 selected screenshots**. Binary files from that newer archive are **not yet all committed in this repo**. This page is an honest inventory and mapping; it does not assert that images are present until uploaded.

## Existing GitHub evidence

- [Tailscale interface](01-tailscale/01-ubuntu-tailscale-interface.png)
- [Eight-packet Tailscale ping](01-tailscale/05-icmp-eight-packets.png)
- [Tailnet devices](01-tailscale/06-tailnet-devices.png)
- [OCI bootstrap and SSH screenshots](02-oracle-cloud/README.md)

## New sanitized archive — intended staging paths

| Phase | Example evidence | Proposed path |
| --- | --- | --- |
| Tailscale | machine status, ping and VPN interface | `screenshots/01-tailscale/extra/` |
| OCI networking | NAT gateway creation, historical IGW, routing, VCN/subnet | `screenshots/02-oracle-cloud/extra/` |
| SSH | private-key validation, successful Tailscale SSH | `screenshots/03-ssh/` |
| Kubernetes | k3s installer, Ready node and system pods | `screenshots/04-kubernetes/` |
| Traefik | ingress class, Traefik service, Ingress object created | `screenshots/05-traefik/` |

**Category correction:** Images showing actual GitHub repository setup are GitHub-interface screenshots, even if captured during the Tailscale documentation phase. They should be described as *Tailscale documentation/repository setup*, not as proof of Tailscale connectivity.

## Sanitization requirements

- Cover personal usernames (including the admin laptop prompt), emails and identifying hostnames.
- Mask real public IPs, tailnet addresses, full OCI OCIDs and interface/MAC identifiers as necessary.
- Completely cover authentication tokens. **Revocation is still required for any exposed valid token.**
- Use irreversible solid redactions; do not rely on blur alone.
- Preserve the command names, Ready/Running states, and successful test output wherever possible.
- Inspect the final exported PNGs manually before publishing publicly.

## Evidence interpretation

Creation forms and selection dialogs document the workflow, not necessarily a completed applied configuration. A Ready Kubernetes node demonstrates node health; it is not proof of an accessible application. An Ingress resource created by `kubectl apply` is not proof of controller reconciliation.
