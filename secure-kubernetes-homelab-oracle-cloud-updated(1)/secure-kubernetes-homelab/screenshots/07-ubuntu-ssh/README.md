# Ubuntu SSH hardening screenshot evidence

| Evidence | Description |
| --- | --- |
| [01-effective-root-login-redacted.png](01-effective-root-login-redacted.png) | Authentic terminal capture of `sudo sshd -T` confirming `permitrootlogin no`; prompt identity redacted. |

The operator also provided a screenshot of a successful non-root SSH login and clean logout. The result is documented in [Ubuntu SSH hardening](../../docs/05-security/ubuntu-ssh-hardening.md), with sensitive identifiers omitted. Original unredacted screenshots must not be published.
