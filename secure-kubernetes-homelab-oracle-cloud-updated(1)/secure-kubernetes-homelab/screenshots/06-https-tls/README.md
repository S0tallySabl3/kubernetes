# Phase 6 — Verified redacted screenshot evidence

Authentic terminal and browser screenshots captured during November 11–12, 2026. Only identifying details (tailnet FQDN, host/user prompt and IP addresses) were blacked out; command and result text remains from the originals. No screenshots were fabricated and no Secret values/private keys were published.

### 1. Certificate and private-key file creation

![Certificate and private-key file creation](01-tailscale-cert-generation-redacted.webp)

### 2. Mode 600 applied to certificate and private key

![Mode 600 applied to certificate and private key](02-cert-file-permissions-redacted.webp)

### 3. Let's Encrypt E2 issuer, subject and validity dates

![Let's Encrypt E2 issuer, subject and validity dates](03-openssl-certificate-details-redacted.webp)

### 4. Owner root/root and mode 600 verified

![Owner root/root and mode 600 verified](04-cert-files-ls-redacted.webp)

### 5. Kubernetes Secret successfully created

![Kubernetes Secret successfully created](05-kubernetes-tls-secret-created.webp)

### 6. Kubernetes TLS Secret type and DATA 2 verified

![Kubernetes TLS Secret type and DATA 2 verified](06-kubernetes-tls-secret-verified.webp)

### 7. Traefik HTTPS Ingress created

![Traefik HTTPS Ingress created](07-traefik-https-ingress-created.webp)

### 8. Both HTTPS and original HTTP Ingress present

![Both HTTPS and original HTTP Ingress present](08-ingress-inventory.webp)

### 9. Traefik TLS Secret, hostname and NGINX backend

![Traefik TLS Secret, hostname and NGINX backend](09-https-ingress-description.webp)

### 10. Windows browser reports Connection Is Encrypted

![Windows browser reports Connection Is Encrypted](10-windows-browser-https-encrypted.webp)

The final Windows PowerShell `curl.exe -vI` output was provided as terminal text, not a screenshot; its redacted transcript is in [Phase 6](../../docs/06-https-tls/README.md). The Tailscale Serve status/reset evidence was also provided as terminal text. An independent internet exposure audit has not been performed.
