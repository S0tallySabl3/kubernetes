# Secure Kubernetes Webserver Lab — Oracle Cloud, Tailscale and k3s

Security-focused infrastructure lab migrated from local Windows/Ubuntu systems to an Oracle Cloud Infrastructure (OCI) VM. The aim is a **privately administered Kubernetes webserver** with reproducible verification and a transparent record of changes.

> **Current state (2026-11-12):** Private OCI Ubuntu VM and k3s with Tailscale administration and working Traefik → NGINX HTTP routing. **Phase 6A:** Tailscale certificate issued. **Phase 6B:** Kubernetes TLS Secret and separate Traefik `websecure` Ingress configured, keeping the existing HTTP Ingress. **Phase 6C:** trusted TLS 1.3 handshake and HTTP/2 200 from NGINX proven **from the OCI VM itself**; still requires separate-laptop test and independent internet-exposure review.

## Current topology

```mermaid
flowchart LR
  Laptop[Authorized tailnet laptop] <-->|Tailscale VPN| VM[OCI Ubuntu VM / k3s]
  VM --> Traefik[Traefik websecure - TLS verified from VM]
  TLS[TLS Secret in webserver] --> Traefik
  Traefik -->|HTTP| Service[NGINX Service :80]
  Service --> NGINX[NGINX pod]
  HTTP[Existing HTTP Ingress preserved] --> Service
  VM -->|Outbound| NAT[OCI NAT Gateway]
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
| Tailscale hostname certificate (Phase 6A) | **Verified issued and protected** | 2026-11-11 CLI, OpenSSL metadata and `ls -l` |
| Phase 6B — TLS Secret and Traefik HTTPS Ingress | **Verified configuration** | 2026-11-11 Secret, Ingress and backend metadata |
| Phase 6C — Live TLS, hostname, HTTP/2 NGINX | **Verified from OCI VM** | 2026-11-12 `curl -vI`, CA/SAN verification and HTTP 200 |
| Phase 6C — external laptop and public exposure | Pending | Separate tailnet client and no-public-ingress audit still required |
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
- [Phase 6A — Tailscale HTTPS certificate and verification](docs/06-https-tls/phase-6a-certificate.md)
- [Phase 6B — Kubernetes Secret and Traefik HTTPS Ingress](docs/06-https-tls/phase-6b-traefik-https.md)
- [Phase 6C — HTTPS/TLS handshake and backend verification](docs/06-https-tls/phase-6c-validation.md)
- [Monitoring and recovery (planned)](docs/07-monitoring/README.md)
- [Evidence inventory and publication guidelines](screenshots/README.md)
- [Change history](CHANGELOG.md)

## Screenshot evidence

Previously committed proof remains under [screenshots/01-tailscale](screenshots/01-tailscale) and [screenshots/02-oracle-cloud](screenshots/02-oracle-cloud). Phase 6A–6C screenshot evidence has been provided and can be retained as separate redacted archives; the newer binary screenshots are not committed in this documentation update. See [the evidence index](screenshots/README.md) for status.

**Publishing policy:** No private SSH keys, Tailscale authentication keys, identity-bearing hostnames, unredacted IP details, cloud OCIDs, account emails, or unredacted originals. Revoke any previously exposed authentication key even if its screenshot is later redacted.

## Roadmap

1. **6A complete:** root-protected Tailscale TLS certificate issued.
2. **6B complete:** namespace TLS Secret and separate host-specific Traefik HTTPS Ingress configured.
3. **6C partial:** trusted HTTPS and NGINX HTTP/2 200 verified on OCI VM. Test from the separate laptop and audit outside exposure/Funnel independently.
4. **6D in progress:** technical documentation updated; sanitized screenshot archives separate.
5. Later: automate certificate/Secret renewal, add Cloudflare Tunnel/CDN/WAF with verified origin TLS, monitor and back up workloads.

Documentation distinguishes **historical setup**, **observed results** and **planned tasks**. Do not interpret screenshots of an OCI creation form as proof of an applied resource.
