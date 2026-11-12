# Phase 6C — Verify Traefik HTTPS, certificate and backend

**Observed test date:** 2026-11-12; HTTP response `Date: Thu, 12 Nov 2026 17:42:00 GMT`.  
**Status:** **PARTIALLY COMPLETE** — real HTTPS, chain trust and NGINX routing verified **from the OCI VM itself**. Still pending: test from the *separate* Ubuntu tailnet laptop and independently verify no public exposure.

## Command and scope

The user supplied output of:

```bash
curl -vI https://YOUR_HOSTNAME.YOUR_TAILNET.ts.net/
```

Replace the example hostname with the real, existing `.ts.net` hostname. The command was executed at the `ubuntu@k8s-vnic` prompt, and curl reported the **same** `100.x` tailnet address for the source and target. Thus this is an on-node, self-addressed HTTPS test, **not** evidence of laptop-to-OCI network reachability.

`-v` displays TLS/connection diagnostics and `-I` requests HTTP response headers with `HEAD`. No `--insecure` or `-k` was used, so certificate verification remained enforced.

## Redacted evidence excerpt

```text
* Host: [REDACTED].ts.net:443 was resolved.
* IPv4: [REDACTED 100.x TAILSCALE IP]
* Trying [REDACTED TAILSCALE IP]:443...
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
* ALPN: server accepted h2
* Server certificate:
*  subject: CN=[REDACTED].ts.net
*  start date: Nov 11 14:14:34 2026 GMT
*  expire date: Feb  9 14:14:33 2027 GMT
*  issuer: C=US; O=Let's Encrypt; CN=E2
*  subjectAltName: host [REDACTED].ts.net matched certificate
* SSL certificate verify ok.
* Established connection ... from [SAME 100.x TAILSCALE IP] ...
* using HTTP/2
> HEAD / HTTP/2
< HTTP/2 200
< content-type: text/html
< server: nginx/1.30.6
< content-length: 896
```

## Verified outcomes

| Test | Evidence | Result |
| --- | --- | --- |
| On-node MagicDNS | Existing `.ts.net` resolves to a Tailscale 100.x address | PASS |
| TCP 443 | Successful TLS connection | PASS (from OCI VM) |
| TLS protocol | TLS 1.3, TLS_AES_128_GCM_SHA256 | PASS |
| Certificate chain | `SSL certificate verify ok` with system trust anchors | PASS |
| Certificate identity | SAN matches requested hostname | PASS |
| Certificate validity | 2026-11-11 to 2027-02-09 UTC | PASS |
| ALPN | HTTP/2 (`h2`) | PASS |
| Traefik -> NGINX routing | `HTTP/2 200`, `Server: nginx/1.30.6` | PASS |
| HTTPS from another tailnet device | Screenshot command executed on `k8s-vnic` itself | **NOT TESTED** |
| Independent public access audit | No external vantage point or complete OCI networking inspection | **NOT TESTED** |
| Funnel state | No independent config verification in this test | **NOT TESTED** |

The result confirms end-to-end application-level TLS termination and successful routing to NGINX **when addressed from the host**. A service can succeed in a self-connection yet remain inaccessible from a different tailnet peer because of firewall, ACL, or routing behavior.

## Remaining Phase 6C actions

**From the separate Tailscale-connected Ubuntu laptop, not the OCI VM:**

```bash
curl -vI https://YOUR_HOSTNAME.YOUR_TAILNET.ts.net/
```

Confirm a matching hostname, `SSL certificate verify ok`, a successful TLS handshake, and the expected HTTP 200/NGINX response. Capture evidence showing the command was initiated from the laptop, but sanitize the prompt, FQDN, source/destination IPs before public documentation.

**Separately review public exposure:** Tailscale Funnel/Serve settings, OCI VNIC public IP assignment, routes, NSG/security lists, host firewalls and any forwarded ports. Neither a passing `curl` nor the use of a NAT Gateway is proof that there is no unsolicited public ingress.

**Operational hardening:** implement renewal of the Tailscale-issued certificate and rotation of the Kubernetes TLS Secret before 2027-02-09, then rerun verification. Cloudflare Tunnel/CDN/WAF is not yet deployed; validate TLS origin hostname/SNI and trust when added, without disabling certificate verification as a permanent workaround.

## Conclusion

**Phase 6C partially verified.** TLS 1.3 handshake, Let's Encrypt certificate chain and SAN, HTTP/2 and an NGINX HTTP 200 have been observed. A separate laptop-origin request and an independent internet exposure check remain outstanding.
