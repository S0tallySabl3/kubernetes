# Phase 01 — Tailscale Deployment

## Objective

Provide a private administration path between an Ubuntu laptop and Windows lab desktop without requiring public router port forwards for management. This phase documents a working connection observed on **November 3, 2026**.

## Components

- **Ubuntu laptop:** Tailscale client and administration workstation.
- **Windows desktop:** Tailscale client and lab workstation.
- **Tailnet:** Private overlay used to connect the two machines.

## Reproducing the installation

The clients are **already installed and connected** in this project. These instructions are for rebuilding on new machines, not steps to repeat on a working host.

### Ubuntu

Use [Tailscale's official Linux installation instructions](https://tailscale.com/docs/install/linux). The supported install script is:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Only execute downloaded install scripts after checking that the source and installation method meet your environment's security requirements. For already connected machines:

```bash
tailscale version
tailscale status
tailscale ip -4
systemctl is-active tailscaled
```

### Windows

Install the official Windows Tailscale client, sign in to the same tailnet, and verify its state in the application or PowerShell:

```powershell
& "$env:ProgramFiles\Tailscale\tailscale.exe" status
```

## Verify connectivity

On the Ubuntu laptop:

```bash
tailscale ping <WINDOWS_TAILSCALE_IP>
ping -c 8 <WINDOWS_TAILSCALE_IP>
```

The OS `ping` may be blocked by Windows firewall rules even when the tailnet is functioning. Do **not** disable host firewalls simply to make a screenshot pass. The observed ICMP test from this project already succeeded with 8/8 packets.

The admin console is available at [Machines](https://login.tailscale.com/admin/machines). Check that both systems appear as connected; this has been observed in the provided capture.

## Results

See [verification.md](verification.md) for the table of original measurements and the three evidence screenshots.

## Troubleshooting

| Symptom | Diagnostic approach |
| --- | --- |
| Ubuntu Tailscale is offline | Check `systemctl status tailscaled` and `tailscale status` |
| Windows command not found | Use the full executable path in PowerShell |
| Machines are not in same tailnet | Check the authenticated tailnet and admin console |
| `tailscale ping` succeeds but OS `ping` fails | Check ICMP firewall policy; don't disable the host firewall wholesale |
| Future VM or Kubernetes node is unreachable | Its routing and identity are separate; being on the Windows host does not automatically add workloads to the tailnet |

## Security practices

- Keep host firewalls enabled.
- Protect identity-provider accounts using MFA.
- Review Tailscale access policies/grants before exposing admin services.
- Avoid public port-forwarding of SSH, RDP, or the Kubernetes API.

