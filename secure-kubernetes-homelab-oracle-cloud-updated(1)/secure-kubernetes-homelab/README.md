# Secure Kubernetes Webserver Lab — Oracle Cloud, Tailscale and k3s

Security-focused infrastructure lab migrated from local Windows/Ubuntu systems to an Oracle Cloud Infrastructure (OCI) VM. The aim is a **privately administered Kubernetes webserver** with reproducible verification and a transparent record of changes.

> **Current documented state (2026-11-13):** Phase 6 private HTTPS deployed: Let's Encrypt certificate from Tailscale → Kubernetes TLS Secret → Traefik HTTPS Ingress → NGINX. After clearing a stale Tailscale Serve proxy, a distinct Windows tailnet client successfully connected via HTTPS; its browser displayed **Connection Is Encrypted** and Windows cURL returned **HTTP/1.1 200 OK**. The independent public-exposure audit and certificate/Secret renewal automation remain outstanding.

## Current topology

```mermaid
flowchart LR
  Windows[Windows tailnet client] -->|Tailscale HTTPS 443 - verified| VM[OCI Ubuntu VM / K3s]
  VM --> Traefik[Traefik TLS termination]
  TLS[Kubernetes TLS Secret] --> Traefik
  Traefik -->|HTTP 80| S[NGINX ClusterIP Service]
  S --> N[NGINX Pod]
  Original[Original HTTP Ingress remains] --> S
  VM -->|Outbound only| NAT[OCI NAT Gateway]
  NAT --> Internet((Internet))
```

The NAT Gateway permits outbound connections but does **not** accept unsolicited inbound internet connections. Tailscale supplies the private administration overlay. The OCI subnet is shown as *Public Subnet* in historical provisioning screenshots; **do not confuse this label with proof of current public VM exposure**. Confirm effective VNIC public-IP assignment, route tables, and OCI security rules before making definitive exposure claims.

## Milestones

| Phase | State | Evidence |
| --- | --- | --- |
| Local Windows ↔ Ubuntu Tailscale | Verified | Eight successful ICMP replies, machine status |
| OCI VCN, VM and initial SSH bootstrap | Completed (historical IGW path) | Earlier OCI and SSH screenshots |
| SSH over Tailscale to OCI VM | Verified | Tailnet ping and SSH login |
| NAT outbound path and removal of Internet Gateway | Reported/tested during migration | Cloud configuration screenshots and connection tests |
| k3s installation | Verified | Installer output |
| k3s single-node readiness | Verified | `kubectl get nodes -o wide` |
| Traefik controller and service | Verified running | `kubectl get pods -n kube-system`, `kubectl get svc traefik -n kube-system`, `kubectl get ingressclass` |
| NGINX Ingress resource | Verified, class `traefik` | 2026-11-10 Traefik-to-NGINX HTTP 200 |
| NGINX pod and Service | Verified Running / ClusterIP | 2026-11-09 all-pods and all-services inventory |
| HTTP access to NGINX via tailnet IP | Verified | 2026-11-09 `curl -I` returned HTTP 200 and NGINX server header |
| Traefik-to-NGINX routing | Verified | 2026-11-10 in-cluster curl to Traefik Service returned NGINX HTTP 200 |
| **Phase 6 — private HTTPS/TLS** | **Verified from Windows client** | TLS certificate, Kubernetes Secret, Traefik HTTPS Ingress, Windows browser encrypted and `curl.exe` HTTP 200; [evidence](docs/06-https-tls/README.md) |
| Independent external exposure audit and TLS renewal automation | Pending | Explicitly separate from working private HTTPS |
| Monitoring, backups and security review | Pending | — |

## Reusable manifests

- [NGINX Ingress (Traefik)](manifests/nginx-ingress.yaml) — observed wildcard-host HTTP `/` routing to `nginx-service:80`.
- [HTTPS Ingress template](manifests/nginx-https-ingress.yaml.tpl) — requires variable expansion before applying; does not reveal hostname.
- [NGINX ClusterIP Service](manifests/nginx-service.yaml) — sanitized declarative YAML from the observed live Service; port 80 forwards to targetPort 8080, selecting `app: nginx`. Deployment and Ingress manifests are pending source inspection.

## Documentation

- [Architecture and migration decisions](docs/architecture.md)
- [Tailscale deployment](docs/01-tailscale/README.md)
- [OCI network history and troubleshooting](docs/02-oracle-cloud/networking.md)
- [OCI SSH troubleshooting](docs/02-oracle-cloud/ssh-and-troubleshooting.md)
- [k3s installation and verification](docs/03-kubernetes/README.md)
- [Traefik and ingress status](docs/04-reverse-proxy/README.md)
- [Phase 5 — workload and Ingress verification](docs/04-reverse-proxy/phase-5-verification.md)
- [Phase 6 — HTTPS/TLS deployment, verification and security notes](docs/06-https-tls/README.md)
- [Monitoring and recovery (planned)](docs/07-monitoring/README.md)
- [Evidence inventory and publication guidelines](screenshots/README.md)
- [Change history](CHANGELOG.md)

## Screenshot evidence

Previously committed proof remains under [screenshots/01-tailscale](screenshots/01-tailscale) and [screenshots/02-oracle-cloud](screenshots/02-oracle-cloud). Phase 6 redacted terminal/browser screenshots are committed under [screenshots/06-https-tls](screenshots/06-https-tls/README.md), with an inventory and links. See [the evidence index](screenshots/README.md).

**Publishing policy:** No private SSH keys, Tailscale authentication keys, identity-bearing hostnames, unredacted IP details, cloud OCIDs, account emails, or unredacted originals. Revoke any previously exposed authentication key even if its screenshot is later redacted.

## Roadmap

1. **Phase 6 complete for private HTTPS:** Certificate, Kubernetes Secret, Traefik ingress, client TLS verification, Serve cleanup and documented evidence.
2. **Security follow-up:** Independently verify no unintended OCI public exposure and evaluate HTTP-to-HTTPS redirect.
3. **Operations follow-up:** Automate certificate and Secret renewal ahead of **2027-02-09** expiry.
4. **Future:** Deploy Cloudflare Tunnel/CDN/WAF with explicitly verified origin TLS trust, then monitoring and recovery.

Documentation distinguishes **historical setup**, **observed results** and **planned tasks**. Do not interpret screenshots of an OCI creation form as proof of an applied resource.
