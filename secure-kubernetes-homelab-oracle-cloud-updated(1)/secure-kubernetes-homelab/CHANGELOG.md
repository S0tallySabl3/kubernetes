# Change log

## 2026-11-09 — k3s and private-access documentation refresh

- Corrected the project's active state: k3s installation, Ready control-plane node, running Traefik controller and Kubernetes ingress object creation now documented with command evidence.
- Updated architecture from **temporary public SSH / Internet Gateway bootstrap** to **Tailscale SSH with NAT egress**; retained historical OCI routing details.
- Documented the distinction between a named NGINX Ingress resource and a running Ingress controller. Traefik remains the observed controller.
- Updated evidence publication guidance and clarified which images are already in GitHub versus still in the local sanitized screenshot archive.
- Did not claim a working application, DNS, HTTPS, or a validated public endpoint.

## 2026-11-05 — Cloud migration documentation update

- Preserved original Tailscale material and three redacted evidence screenshots.
- Replaced local-only project overview with OCI architecture and separate Tailscale history.
- Added OCI public subnet, internet gateway, route table, ingress-table distinction, SSH troubleshooting and verification pages.
- Added curated redacted OCI images, including successful SSH login, without raw IP/account identifiers.
- At that point Kubernetes, HTTPS and monitoring were pending.
