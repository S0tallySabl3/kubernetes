# Change log

## 2026-11-20 — Automate OpenSSH authentication hardening with Ansible

- Established Ansible management from the Ubuntu laptop using an INI inventory and SSH transport over Tailscale; inventory parsing and `ansible.builtin.ping` succeeded.
- Published [the reusable SSH hardening playbook](ansible/playbooks/harden-ssh.yml) enforcing four OpenSSH authentication directives via a managed drop-in.
- Observed a successful update: file task `changed`, syntax check handler `ok`, SSH reload `changed`; recap `ok=3 changed=2 failed=0 unreachable=0`.
- Successfully established a new SSH session from the Ubuntu laptop after the playbook ran.
- Added [automation deployment notes](ansible/README.md) and a placeholder-only [INI inventory template](ansible/inventory.example.ini), keeping actual private keys and device addresses out of the repository.
- Preserved earlier manually verified host hardening notes; the Ansible deployment is a separate automation milestone.

## 2026-11-19 — Ubuntu rpcbind service hardening

- Investigated `rpcbind` after port 111 was observed listening on IPv4 and IPv6 (TCP/UDP).
- Checked reverse systemd dependencies, NFS mounts and registered RPC programs; no additional RPC program was registered, and no NFS mount was visible on the host.
- Disabled and stopped `rpcbind.socket` and `rpcbind.service` using `systemctl disable --now`.
- Verified both units inactive and disabled, then confirmed `ss` returned no TCP/UDP port 111 listeners.
- Added [methodology and validation record](docs/05-security/ubuntu-rpcbind-hardening.md) plus an [authentic redacted screenshot](screenshots/08-ubuntu-rpcbind/01-port-111-no-listeners-redacted.png) with identifying terminal prompt removed.

## 2026-11-17 — Ubuntu OpenSSH root-login hardening

- Reviewed effective OpenSSH authentication settings: public-key authentication enabled; password and keyboard-interactive authentication disabled; direct root key authentication initially permitted by `prohibit-password`.
- Created an OpenSSH drop-in setting `PermitRootLogin no`.
- Verified the effective setting using `sudo sshd -T`; a subsequent fresh key-based SSH login to the non-root Ubuntu administration account succeeded.
- Added [Ubuntu SSH hardening documentation](docs/05-security/ubuntu-ssh-hardening.md) and sanitized terminal evidence under [screenshots/07-ubuntu-ssh](screenshots/07-ubuntu-ssh/README.md).
- Did not publish usernames, IP addresses, full hostnames or private-key filenames.

## 2026-11-16 — Tailscale Zero Trust access-control hardening

- Replaced the Tailscale general allow-all grant with one restricted to two designated client devices, the `tag:cloud-server` destination, and TCP ports 22 and 443.
- Verified the wildcard general access rule no longer appeared in the Policies interface.
- Confirmed the HTTPS webserver continued to load after the change.
- Observed `Test-NetConnection` over the Tailscale interface: port 6443 returned `TcpTestSucceeded: False` while basic ping succeeded.
- Recorded the successful key-based SSH login obtained during the policy transition; did not treat a separate VPN-interface failure as definitive grant enforcement.
- Added [the hardening rationale and sanitized validation transcript](docs/01-tailscale/access-control-hardening.md). No device IPs, accounts, or full tailnet hostnames were committed.

## 2026-11-13 — Consolidate Phase 6 private HTTPS/TLS and redacted evidence

- Consolidated former Phase 6A–6D notes into [one Phase 6 document](docs/06-https-tls/README.md), with verified commands, architecture diagrams and redacted evidence.
- Confirmed Windows HTTPS success on 2026-11-12 after clearing a stale Tailscale Serve mapping (`127.0.0.1:8080`) using `tailscale serve reset`. A Windows browser reported **Connection Is Encrypted** and `curl.exe -vI` returned `HTTP/1.1 200 OK` from `nginx/1.30.6`.
- Published ten authentic, **redacted** certificate, Kubernetes and browser screenshots. No private keys, TLS Secret data, full tailnet hostnames, prompt identities or client/server IPs were committed.
- Three certificate SHA-256 fingerprints (on-host file, Kubernetes TLS Secret and Traefik-served certificate) matched exactly in operator output; raw fingerprint omitted from documentation.

## 2026-11-10 — Diagnostic test pod cleanup confirmed

- Ran `sudo k3s kubectl delete pod ingress-test --ignore-not-found`.
- Kubernetes returned `pod "ingress-test" deleted from default namespace`.
- Recorded successful deletion response.
- Source terminal screenshot contains an identifying prompt and is not published unredacted.


## 2026-11-10 — Phase 5 Traefik-to-NGINX routing confirmed

- Created a temporary `curlimages/curl` pod and confirmed it entered Running state.
- Executed an HTTP HEAD request to `http://traefik.kube-system.svc.cluster.local/` from the pod using `kubectl exec`.
- DNS resolution succeeded; TCP connected to Traefik Service port 80; response was **HTTP/1.1 200 OK**, with `Server: nginx/1.30.6` and `Content-Length: 896`.
- Marked **Traefik → NGINX HTTP ingress routing verified**.
- Redacted original terminal screenshot for evidence; binary screenshot retained as a separate downloadable file, not committed to GitHub.
- Diagnostic pod cleanup is recorded in the following entry.


## 2026-11-10 — Publish sanitized Traefik Ingress manifest

- Added `manifests/nginx-ingress.yaml` matching observed `webserver/nginx-ingress`: class `traefik`, hostless `/` Prefix rule, backend `nginx-service:80`.
- Verified Traefik LoadBalancer Service exists (ports 80 and 443 via K3s ServiceLB NodePorts); exact private addresses omitted from committed manifests.
- Removed generated Ingress metadata/status fields from the reusable YAML. Routing was subsequently verified.
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
