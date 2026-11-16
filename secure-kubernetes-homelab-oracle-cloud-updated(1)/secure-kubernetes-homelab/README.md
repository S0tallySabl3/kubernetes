# Kubernetes Webserver Infrastructure Lab — Oracle Cloud, Tailscale and K3s

Hands-on infrastructure lab deployed on Oracle Cloud Infrastructure (OCI), using Tailscale for private access, K3s for Kubernetes orchestration, Traefik for ingress routing, and NGINX as a web workload. The focus is **deploying fundamental infrastructure and applying basic, demonstrable hardening measures**, with documented configuration and verification.

> **Current documented state (2026-11-16):** Phase 6 private HTTPS deployed: Let's Encrypt certificate from Tailscale → Kubernetes TLS Secret → Traefik HTTPS Ingress → NGINX. After clearing a stale Tailscale Serve proxy, a distinct Windows tailnet client successfully connected via HTTPS; its browser displayed **Connection Is Encrypted** and Windows cURL returned **HTTP/1.1 200 OK**.

## Verified foundational security measures

- Replaced the unrestricted Tailscale general access grant with a rule for two authorized tailnet devices to reach the cloud server on TCP 22 and 443; verified HTTPS availability and a failed TCP 6443 test over Tailscale. [Access-control record](docs/01-tailscale/access-control-hardening.md).
- Migrated administration from temporary public SSH bootstrap to private SSH access over Tailscale.
- Configured outbound access through an OCI NAT Gateway and removed the bootstrap Internet Gateway (as recorded in the migration tests).
- Terminated client HTTPS at Traefik using a trusted certificate stored as a Kubernetes TLS Secret, with restricted certificate key-file permissions on the VM.
- Kept credential material and identifying infrastructure details out of the documented manifests and published evidence wherever verified.


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

The NAT Gateway provides outbound connectivity, while Tailscale supplies the private administration overlay. Historical provisioning screenshots document the initial networking configuration.

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
| **Tailscale access-control hardening** | **Restricted grant applied and tested** | Wildcard grant removed; HTTPS works; TCP 6443 refused via Tailscale; [validation record](docs/01-tailscale/access-control-hardening.md) |

## Reusable manifests

- [NGINX Ingress (Traefik)](manifests/nginx-ingress.yaml) — observed wildcard-host HTTP `/` routing to `nginx-service:80`.
- [HTTPS Ingress template](manifests/nginx-https-ingress.yaml.tpl) — requires variable expansion before applying; does not reveal hostname.
- [NGINX ClusterIP Service](manifests/nginx-service.yaml) — sanitized declarative YAML from the observed live Service; port 80 forwards to targetPort 8080, selecting `app: nginx`. This manifest records the observed Service configuration.

## Documentation

- [Architecture and migration decisions](docs/architecture.md)
- [Tailscale deployment](docs/01-tailscale/README.md)
- [Tailscale Zero Trust access-control hardening and validation](docs/01-tailscale/access-control-hardening.md)
- [OCI network history and troubleshooting](docs/02-oracle-cloud/networking.md)
- [OCI SSH troubleshooting](docs/02-oracle-cloud/ssh-and-troubleshooting.md)
- [k3s installation and verification](docs/03-kubernetes/README.md)
- [Traefik and ingress status](docs/04-reverse-proxy/README.md)
- [Phase 5 — workload and Ingress verification](docs/04-reverse-proxy/phase-5-verification.md)
- [Phase 6 — HTTPS/TLS deployment, verification and security notes](docs/06-https-tls/README.md)
- [Evidence inventory and publication guidelines](screenshots/README.md)
- [Change history](CHANGELOG.md)

## Screenshot evidence

Previously committed proof remains under [screenshots/01-tailscale](screenshots/01-tailscale) and [screenshots/02-oracle-cloud](screenshots/02-oracle-cloud). Phase 6 redacted terminal/browser screenshots are committed under [screenshots/06-https-tls](screenshots/06-https-tls/README.md), with an inventory and links. See [the evidence index](screenshots/README.md).

**Publishing policy:** Private keys, credentials, authentication tokens and sensitive account details are excluded from published materials.

## Project outcome

The completed lab demonstrates a Kubernetes webserver hosted on OCI, private access through Tailscale, Traefik ingress routing, and HTTPS connectivity verified from a separate Windows client. Configuration examples and redacted verification evidence accompany the deployment notes.
