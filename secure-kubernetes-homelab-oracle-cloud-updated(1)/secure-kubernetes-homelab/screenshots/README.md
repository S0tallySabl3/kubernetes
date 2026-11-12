# Screenshot evidence inventory

Only **sanitized** terminal/console screenshots may be published. Original screenshots remain outside the repository. Always remove identifying usernames, internal names, full tailnet domains, cloud identifiers, externally routable IPs, SSH/Tailscale auth keys and any private certificate or Secret bytes. Retain the command and security-result text whenever possible.

## Already tracked

- [Tailscale evidence](01-tailscale/README.md) — earlier tailnet connectivity and ICMP tests.
- [OCI evidence](02-oracle-cloud/) — earlier cloud build/SSH verification screenshots.

## Prepared, not included in this commit

**2026-11-11 — Phase 6A TLS** (four redacted original terminal captures, provided separately in the chat archive):

| Image | What it verifies | Repository binary status |
| --- | --- | --- |
| `01-tailscale-cert-generation-redacted.png` | CLI wrote certificate and key files | Not uploaded |
| `02-cert-file-permissions-redacted.png` | `chmod 600` commands | Not uploaded |
| `03-openssl-certificate-details-redacted.png` | Issuer, hostname match, UTC validity dates | Not uploaded |
| `04-cert-files-ls-redacted.png` | `root:root` ownership and `-rw-------` mode | Not uploaded |

The commands, observed results, and security caveats are fully recorded in [Phase 6A documentation](../docs/06-https-tls/phase-6a-certificate.md). This index intentionally does **not** link to nonexistent images or claim they have been committed.

## Phase 6B/6C screenshot evidence — prepared separately, not uploaded here

| Evidence | Outcome | Repository binary |
| --- | --- | --- |
| 6B Secret creation | Created `nginx-tailscale-tls` | Not uploaded |
| 6B Secret namespace verification | `kubernetes.io/tls`, DATA 2 | Not uploaded |
| 6B HTTPS Ingress creation | `nginx-https-ingress` created | Not uploaded |
| 6B Ingress list | Both HTTP and HTTPS Ingress present | Not uploaded |
| 6B Ingress description | Correct Secret, Traefik, host and NGINX backend | Not uploaded |
| 6C verbose curl | TLS 1.3, matching certificate/chain, HTTP/2 200 NGINX | Not uploaded |

Screenshots contain full hostname and network IPs in originals; redact identifying prompts, real `.ts.net` domain and private/Tailscale IP addresses before sharing. The 6C screenshot is **from the OCI VM itself, not the laptop**. Sanitized transcripts are in [6B](../docs/06-https-tls/phase-6b-traefik-https.md) and [6C](../docs/06-https-tls/phase-6c-validation.md).
