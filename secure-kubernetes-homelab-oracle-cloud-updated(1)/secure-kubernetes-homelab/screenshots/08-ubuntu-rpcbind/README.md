# Ubuntu rpcbind hardening — Screenshot evidence

| File | What it proves |
| --- | --- |
| [01-port-111-no-listeners-redacted.png](01-port-111-no-listeners-redacted.png) | Authentic terminal screenshot after hardening: `sudo ss -tulpen '( sport = :111 )'` returns only headers, without TCP/UDP port 111 listeners |

The original screenshot was cropped to the command-and-output area and the identifying shell prompt and terminal tab were masked. No command output was changed. The earlier `rpcbind` service status, dependency tests, and RPC registrations are transcribed in the [hardening record](../../docs/05-security/ubuntu-rpcbind-hardening.md).
