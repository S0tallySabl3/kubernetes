# Change log

## 2026-11-09 — Publish clean NGINX Service manifest

- Added `manifests/nginx-service.yaml` using observed Service spec (`ClusterIP`, selector `app: nginx`, TCP 80 → 8080).
- Omitted generated Service UID, timestamps, resourceVersion, and allocated ClusterIP.
- Prepared separately redacted screenshot of the live Service YAML; image is not yet committed to the repository.


## 2026-11-09 — Ingress backend and private HTTP tests

- `kubectl describe ingress nginx-ingress -n webserver` shows Traefik IngressClass and NGINX service backend on port 80.
- `kubectl get endpointslices -n webserver -l kubernetes.io/service-name=nginx-service` identifies a backend endpoint on port 8080.
- A tailnet-IP `curl -I` returned **HTTP/1.1 200 OK**, `Content-Type: text/html`, and `Server: nginx/1.30.6`.
- The successful HTTP response establishes reachability, but not conclusively whether that request traversed Traefik; a controlled Ingress test remains open.
- Three new screenshots redacted locally; evidence archive exists separately and is not yet committed as binary images.


## 2026-11-09 — Phase 5 resource inventory

- Verified all-namespaces pod and Service listings; NGINX pod healthy with zero restarts and `nginx-service` exposed internally on TCP/80.
- Verified `nginx-ingress` in namespace `webserver` selects the `traefik` IngressClass; ingress status includes an address.
- Confirmed `traefik` is the default registered controller class.
- Added [Phase 5 verification](docs/04-reverse-proxy/phase-5-verification.md) and clarified that end-to-end HTTP routing remains untested.
- Four terminal screenshots sanitized locally; binary evidence needs separate repository upload.


## 2026-11-09 — Correct documentation build order

- Renumbered phases to follow deployment dependencies: 01 Tailscale, 02 Oracle Cloud/Ubuntu, 03 Kubernetes/k3s, 04 Traefik ingress, 05 Security, 06 Monitoring.
- Preserved existing documentation content and updated cross-references.

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
