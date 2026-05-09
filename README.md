# SmbShare.Linux

[![Pester Tests](https://github.com/peppekerstens/SmbShare.Linux/actions/workflows/pester.yml/badge.svg)](https://github.com/peppekerstens/SmbShare.Linux/actions/workflows/pester.yml)

PowerShell 7.x module providing cmdlet parity with the Windows `SmbShare` / NFS modules on Linux. Wraps `smbstatus`, `nfsstat`, and `mount` to inspect SMB connections and NFS client configuration from a familiar PowerShell interface.

Part of the **Linux PowerShell Cmdlet Parity** project — inspired by Evgenij Smirnov's [2025 European PowerShell Summit session](https://www.youtube.com/watch?v=RlzinWYIjBY) and documented in the blog series at [peppekerstens.github.io](https://peppekerstens.github.io/linux-command-wrapping-part-1/).

---

## What it does

On **Linux**, wraps Samba (`smbstatus`) and NFS kernel tools (`nfsstat`, `mount`, `/etc/nfs.conf`) to surface SMB and NFS information via PowerShell objects. 3 cmdlets are fully implemented; broader SmbShare parity (share management, access control) requires Samba to be installed and is not yet covered.

On **Windows**, the module refuses to load — use the built-in `SmbShare` module.

> **Note:** `smbstatus` requires Samba to be installed. Tests that depend on it are skipped automatically when Samba is absent (e.g. in WSL2).

---

## Requirements

- PowerShell 7.2+
- **Linux only** — the module refuses to load on Windows
- `smbstatus` (Samba) for `Get-SmbConnection` — `sudo apt install samba`
- `nfsstat` for `Get-NfsSession` — `sudo apt install nfs-common`
- `/etc/fstab` and optionally `/etc/nfs.conf` for `Get-NfsClientConfiguration`

---

## Installation

```powershell
# Clone or copy the module folder to a PSModulePath location, then:
Import-Module SmbShare.Linux
```

---

## Usage

```powershell
# List active SMB connections (requires Samba)
Get-SmbConnection

# Filter by server
Get-SmbConnection -ServerName 'fileserver01'

# Show NFS client session statistics
Get-NfsSession

# Show NFS mounts from /etc/fstab and /etc/nfs.conf
Get-NfsClientConfiguration
```

---

## Cmdlet Status

Legend: ✅ Implemented &nbsp;|&nbsp; ⚠️ Stub

| Cmdlet | Status | Linux tool | Notes |
|---|:---:|---|---|
| `Get-SmbConnection` | ✅ | `smbstatus -b` | ServerName, UserName, Dialect, Encryption; `-ServerName` filter; requires Samba |
| `Get-NfsSession` | ✅ | `nfsstat -c` | NFS client I/O statistics from kernel; requires `nfs-common` |
| `Get-NfsClientConfiguration` | ✅ | `mount` + `/etc/nfs.conf` + `/etc/fstab` | NFS mount points and client config; no external daemon needed |

---

## Implementation notes

- `Get-SmbConnection` parses `smbstatus -b` (brief mode). The connections section starts after the first `---` separator. Columns are split on 2+ whitespace.
- `Get-NfsSession` reads `nfsstat -c` text output. Skips header lines; parses kernel NFS client counters.
- `Get-NfsClientConfiguration` reads `/etc/nfs.conf` (if present) and scans `/etc/fstab` for NFS-type entries. No daemon or root access required.
- No Crescendo: all implementations are hand-written functions; JSON Crescendo files exist as design documentation only.

---

## CI / Testing

Tested across 5 Linux distributions in containers (Samba/NFS tests skip automatically when tools are absent):

| Distro | Image |
|---|---|
| Ubuntu 24.04 | `ghcr.io/peppekerstens/testinfra:ubuntu-24.04` |
| Debian 12 | `ghcr.io/peppekerstens/testinfra:debian-12` |
| Fedora 40 | `ghcr.io/peppekerstens/testinfra:fedora-40` |
| openSUSE Tumbleweed | `ghcr.io/peppekerstens/testinfra:opensuse-tumbleweed` |
| Arch Linux | `ghcr.io/peppekerstens/testinfra:arch-latest` |

Run locally with:

```powershell
# From the repo root
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

GitHub Actions runs the same matrix on every push — see `.github/workflows/pester.yml`.

---

## Version history

| Version | Notes |
|---|---|
| 0.1.0 | Initial release. `Get-SmbConnection`, `Get-NfsSession`, `Get-NfsClientConfiguration` implemented. Multi-distro GHA + docker-compose. |

---

## License

GPL-3.0 — see [LICENSE](LICENSE).
