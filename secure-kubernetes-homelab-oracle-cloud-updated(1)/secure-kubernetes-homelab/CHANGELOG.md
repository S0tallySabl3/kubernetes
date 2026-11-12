# Change log

## 2026-11-12 — Phase 6C: HTTPS verified from OCI VM

- `curl -vI` successfully negotiated TLS 1.3 with Let's Encrypt E2, verified chain/SAN, ALPN h2, and `HTTP/2 200` from `nginx/1.30.6`.
- Command ran at `ubuntu@k8s-vnic`, with matching source/target tailnet IP. This was **not** the separate Ubuntu laptop; off-node reachability is pending.
- No independent public exposure or Funnel review was performed. Phase 6C remains partially complete.
- See [Phase 6C verification](docs/06-https-tls/phase-6c-validation.md).

## 2026-11-11 — Phase 6B: TLS Secret and HTTPS Ingress created

- Created `webserver/nginx-tailscale-tls` from protected files; verified `kubernetes.io/tls`, `DATA 2`.
- Created `webserver/nginx-https-ingress` with Traefik `websecure`, TLS enabled, existing tailnet hostname and `nginx-service:80` backend.
- Verified via Ingress inventory and description that original `nginx-ingress` remains, with HTTPS resource and endpoint present.
- Added sanitized [Phase 6B documentation](docs/06-https-tls/phase-6b-traefik-https.md) and an Ingress YAML template (no key/Secret bytes).

## 2026-11-11 — Phase 6A certificate issuance verified

- Generated a Let's Encrypt E2 certificate via `sudo tailscale cert` for the existing `.ts.net` machine hostname; recorded only redacted hostname details.
- Confirmed certificate file and private key were written to `/etc/tailscale/certs/`, owner `root:root` and permission mode `600`.
- Recorded X.509 validity window (2026-11-11 14:14:34 UTC through 2027-02-09 14:14:33 UTC) and matching SAN.
- Prepared four terminal screenshots with identifying prompts and hostname redacted; binaries remain available separately and are not committed with the text documentation.
- Added [Phase 6A notes](docs/06-https-tls/phase-6a-certificate.md) and aligned the existing monitoring documentation with Phase 7 numbering.
- **Not yet done:** Kubernetes TLS Secret, HTTPS Ingress, TLS client handshake, automated renewal, independent origin exposure audit, or Cloudflare deployment.

## 2026-11-10 — Diagnostic test pod cleanup confirmed

- Ran `sudo k3s kubectl delete pod ingress-test --ignore-not-found`.
- Kubernetes returned `pod "ingress-test" deleted from default namespace`.
- Recorded successful deletion response. A separate post-deletion pod listing has not been captured.
- Source terminal screenshot contains an identifying prompt and is not published unredacted.


## 2026-11-10 — Phase 5 Traefik-to-NGINX routing confirmed

- Created a temporary `curlimages/curl` pod and confirmed it entered Running state.
- Executed an HTTP HEAD request to `http://traefik.kube-system.svc.cluster.local/` from the pod using `kubectl exec`.
- DNS resolution succeeded; TCP connected to Traefik Service port 80; response was **HTTP/1.1 200 OK**, with `Server: nginx/1.30.6` and `Content-Length: 896`.
- Marked **Traefik → NGINX HTTP ingress routing verified**. TLS, client hostname resolution, and external exposure audit remain pending.
- Redacted original terminal screenshot for evidence; binary screenshot retained as a separate downloadable file, not committed to GitHub.
- Temporary diagnostic pod must be manually deleted after testing.


## 2026-11-10 — Publish sanitized Traefik Ingress manifest

- Added `manifests/nginx-ingress.yaml` matching observed `webserver/nginx-ingress`: class `traefik`, hostless `/` Prefix rule, backend `nginx-service:80`.
- Verified Traefik LoadBalancer Service exists (ports 80 and 443 via K3s ServiceLB NodePorts); exact private addresses omitted from committed manifests.
- Removed generated Ingress metadata/status fields from the reusable YAML. No routing traffic test completed in this step.
- Two redacted terminal screenshots packaged separately; binary evidence not yet uploaded to GitHub.


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
