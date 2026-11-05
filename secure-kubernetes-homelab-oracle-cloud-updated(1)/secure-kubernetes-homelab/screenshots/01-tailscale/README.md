# Screenshot Evidence — Phase 01

The following PNGs were created by overlaying **opaque redaction rectangles onto the original uploaded screenshots**. The underlying screenshot content is not recreated or altered outside those regions. Opaque blocks are used rather than weak blur for account identifiers and internal IPs.

| Screenshot | What it demonstrates | Status |
| --- | --- | --- |
| [`01-ubuntu-tailscale-interface.png`](01-ubuntu-tailscale-interface.png) | Tailscale Linux network interface is UP/RUNNING | Captured |
| [`05-icmp-eight-packets.png`](05-icmp-eight-packets.png) | 8 transmitted, 8 received, 0% loss | Captured |
| [`06-tailnet-devices.png`](06-tailnet-devices.png) | Windows and Ubuntu devices show Connected in admin console | Captured |
| `02-windows-tray-connected.png` | Windows tray details | Not yet captured |
| `03-windows-powershell-status.png` | Windows status command | Not yet captured |
| `04-tailscale-ping.png` | Tailscale-native ping | Not yet captured |

## Preservation rule

1. Keep original captures **outside** this public repository.
2. Redact only machine identifiers, email addresses, account details, network addresses, usernames, and credentials that should not be public.
3. Do not re-render terminal text, insert new output, modify test statistics, or invent configuration states.
4. Inspect the complete sanitized image before publishing; `.gitignore` cannot detect secrets embedded in PNGs.

Screenshots are evidence of an observed state on the collection date, not a guarantee of future availability.
