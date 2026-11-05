# OCI screenshot index and redaction policy

| File | Interpretation |
| --- | --- |
| `01-internet-gateway-creation-redacted.png` | Gateway creation form; not independent proof that settings were saved |
| `02-original-gateway-route-table-association-redacted.png` | Original association later corrected; troubleshooting history |
| `03-dedicated-ingress-route-table-redacted.png` | Dedicated IGW ingress table marked available |
| `04-dedicated-ingress-association-redacted.png` | IGW route table association form |
| `05-public-subnet-default-route-form-redacted.png` | Subnet default route settings entered |
| `06-successful-ssh-redacted.png` | SSH login succeeded; remote Ubuntu shell visible |

## Provenance warning

These six images are **previously edited/redacted exhibit files from the project conversation**, not unedited forensic originals. Some prior image processing regenerated visual presentation rather than strictly masking original pixels. Consequently, do not describe them as *pixel-identical outside redacted regions*. The successful SSH output is supported by the original screenshot shown in the project conversation, but the distributed edit is a sanitized reproduction of the displayed UI.

The three legacy Tailscale screenshots in `../01-tailscale/` were prepared as opaque-redaction overlays on original captures, as documented separately.

## Publishing rule

Never commit the original screenshots containing local login identity (including `lian@lian`), public source/target IPs, account compartment names, tenancy/route OCIDs, private key data, or session tokens. The published SSH exhibit intentionally hides the local login string, private-key filename detail, public target IP and last-login source IP.

Redaction should preserve the **meaning** of technical validation (the OS banner and successful remote prompt). Review every image visually before publishing, especially if replacing a sanitized image later.
