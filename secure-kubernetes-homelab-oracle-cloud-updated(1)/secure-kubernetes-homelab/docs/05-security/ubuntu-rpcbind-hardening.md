# Ubuntu Host Hardening — Disable Unused rpcbind Service

**Recorded:** November 19, 2026  
**System:** Oracle Cloud Ubuntu server running K3s  
**Scope:** Host-level `rpcbind` service and its TCP/UDP port 111 listeners. The Kubernetes workloads and network infrastructure were not modified.

## Objective

Reduce the server's network-facing attack surface by disabling an RPC port-mapping service that was not found to be required by the current lab configuration.

The change followed an inspection-first methodology: identify the exposed service, understand it, check visible dependencies and usage, apply a reversible change, and independently verify the resulting network sockets.

## Baseline findings

An earlier `sudo ss -tulpen` inspection showed `rpcbind` listening on TCP and UDP port 111. The follow-up command:

```bash
systemctl status rpcbind.socket rpcbind.service --no-pager
```

showed both units **active (running)** and **enabled**. The socket unit listed IPv4 wildcard (`0.0.0.0:111`) and IPv6 wildcard (`[::]:111`) listeners for TCP and UDP.

`rpcbind` provides RPC program-to-port mapping, commonly relevant to certain NFS configurations. The exposed host service was therefore investigated before disabling it.

## Dependency and usage assessment

| Read-only check | Result | Interpretation |
| --- | --- | --- |
| `systemctl list-dependencies --reverse rpcbind.service --all --no-pager` | Displayed `rpcbind.service`, `multi-user.target`, and `graphical.target` | No NFS service appeared in the displayed reverse-dependency tree |
| `findmnt -t nfs,nfs4` | No output | No NFS mount was visible in the host mount namespace |
| `rpcinfo -p localhost` | Program `100000` (`portmapper`) only, TCP/UDP port 111, versions 2–4 | No other RPC programs were registered with rpcbind at the time of inspection |

These findings support disabling rpcbind for the currently observed workload. They do **not** prove that no future software or Kubernetes workload could require an RPC service.

## Configuration change

Both the service and its systemd activation socket were disabled and stopped:

```bash
sudo systemctl disable --now rpcbind.socket rpcbind.service
```

The `--now` option stops the running units immediately; `disable` removes their normal startup enablement. Disabling the socket matters because socket activation could otherwise leave the listening endpoint available.

This change does not uninstall rpcbind or mask the units.

### Rollback

If RPC-dependent functionality is subsequently required, restore the prior normal activation state using:

```bash
sudo systemctl enable --now rpcbind.socket rpcbind.service
```

Investigate the dependency before performing rollback or changing the service configuration.

## Validation

### Systemd unit status

The operator supplied `systemctl status rpcbind.socket rpcbind.service --no-pager` output after the change. Both units showed:

```text
Loaded: ... disabled; preset: enabled
Active: inactive (dead)
```

The journal in the same output confirmed that the socket closed and the service stopped.

`preset: enabled` describes the vendor default, **not** the current unit enablement state. The active configuration was disabled.

### Port 111 listening-socket inspection

The operator ran:

```bash
sudo ss -tulpen '( sport = :111 )'
```

The terminal returned only the column headers, with **no matching TCP or UDP socket**.

![Redacted host socket inspection showing no listeners on TCP/UDP port 111](../../screenshots/08-ubuntu-rpcbind/01-port-111-no-listeners-redacted.png)

**Interpretation:** On the inspected host, no network sockets were listening on local port 111 at the time of this test. This validates removal of the previously observed rpcbind listeners. It does not by itself test remote firewall policies or provide assurance about unrelated ports.

## Result and lessons learned

- **Before:** `rpcbind.socket` and `rpcbind.service` were active and enabled; TCP/UDP 111 listeners existed on IPv4 and IPv6.
- **After:** Both systemd units were inactive and disabled; `ss` displayed no TCP/UDP 111 listeners.
- **Method:** Service discovery → dependency review → reversible hardening change → socket-level validation.
- **Documentation safety:** The screenshot is cropped from the user's original terminal capture with the identifying host/user prompt masked. Command text and observed result are preserved.

This milestone covers only the Ubuntu host rpcbind service. No additional host or Kubernetes hardening is claimed.
