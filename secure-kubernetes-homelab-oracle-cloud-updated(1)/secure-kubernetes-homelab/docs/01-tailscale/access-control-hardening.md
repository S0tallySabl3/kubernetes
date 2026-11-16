# Tailscale Zero Trust Access Control — Least-Privilege Grant

**Recorded:** November 16, 2026  
**System:** Tailscale tailnet  
**Scope:** Access-policy hardening for the existing private Kubernetes webserver. No changes to the Kubernetes cluster, OCI network, Traefik, or NGINX were part of this milestone.

## Objective and rationale

Replace unrestricted tailnet-to-tailnet access with explicit authorization for the administrative clients to reach the cloud-hosted webserver. A network connection should not itself grant permission to access every destination and port.

The previous general grant permitted any tailnet source to reach any tailnet destination using any port and protocol:

```json
{ "src": ["*"], "dst": ["*"], "ip": ["*"] }
```

Tailscale grants are additive: adding a narrow grant does not override a broader existing grant. Therefore, the wildcard grant had to be removed for the new restriction to take effect.

## Implemented configuration

- **Approved sources:** Windows desktop and Ubuntu laptop, selected by their respective Tailscale device IPs in the live policy.
- **Destination:** `tag:cloud-server`, assigned to the OCI-hosted Kubernetes server.
- **Allowed TCP ports:** `22` (SSH) and `443` (HTTPS).
- **Change:** Saved the specific grant, then deleted the original wildcard allow-all rule.
- **Backup:** The pre-hardening policy was recommended for private backup; this repository does not contain a policy backup.

Sanitized *illustration* of the general grant (the placeholders are not valid live policy selectors):

```json
{
  "src": ["<WINDOWS_TAILSCALE_IP>", "<UBUNTU_TAILSCALE_IP>"],
  "dst": ["tag:cloud-server"],
  "ip": ["tcp:22", "tcp:443"]
}
```

The Tailscale general access rules page was subsequently observed with only this restricted rule, and no wildcard allow-all grant.

## Validation evidence

| Check | Observed result | Interpretation |
| --- | --- | --- |
| General access policy | Only the restricted grant appeared in the Policies screenshot | Wildcard rule removed from general grants |
| SSH from Windows using a key | A fresh session authenticated successfully during the policy transition | Positive SSH connectivity demonstrated at that point |
| Web application from Windows | NGINX welcome page loaded through the Tailscale HTTPS hostname after wildcard removal | Permitted HTTPS access was preserved |
| Tailscale path for port-restriction test | PowerShell displayed `InterfaceAlias: Tailscale` and `SourceAddress` as the Windows tailnet address | Test traversed the Tailscale interface |
| TCP port 6443 | `TcpTestSucceeded: False`, with `PingSucceeded: True` | Unapproved TCP connection failed despite basic host reachability |

### Sanitized validation transcript

The following is a *transcription of visible test fields*, not a raw shell export. Hostnames, identities, and IP addresses are intentionally omitted.

```powershell
PS> tailscale status
# Windows client and cloud server listed in the tailnet.

PS> Test-NetConnection <CLOUD_SERVER_TAILSCALE_IP> -Port 6443
RemotePort       : 6443
InterfaceAlias   : Tailscale
PingSucceeded    : True
TcpTestSucceeded : False
```

The failed connection to port 6443 is consistent with the new grant, which allows only TCP 22 and 443. The negative result alone does not identify the precise enforcement point, but it supports the access-control outcome when considered alongside the saved policy and successful permitted-service tests.

The SSH login screenshot was captured before final removal of the wildcard rule was independently shown, so it is recorded as an earlier successful connectivity test rather than a post-removal retest. A separate SSH attempt using another VPN interface failed, but was not used as definitive evidence of Tailscale policy enforcement because routing can affect that result.

## Result

A least-privilege general access grant now limits the two specified tailnet clients to SSH and HTTPS on the tagged webserver. The unrestricted general grant was removed, and permitted HTTPS plus denied TCP 6443 were observed under the updated configuration.

This record covers **Tailscale access control only**. The original screenshots were reviewed but are not reproduced here because they contain device identifiers; the sanitized transcript above preserves the specific test outcomes without publishing them.

## Related documentation

- [Initial Tailscale deployment](README.md)
- [Tailscale connectivity verification](verification.md)
- [Foundational security measures](../05-security/README.md)
