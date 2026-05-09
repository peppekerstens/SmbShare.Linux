#Requires -Version 7.2

# SmbShare.Linux.psm1
# Root module for SmbShare.Linux.
# Dot-sources all function files from the Functions\ subdirectory.

# Linux-only guard — this module wraps Linux SMB/NFS tools and must not be loaded on Windows.
# On Windows, use the built-in SmbShare/NFS modules instead.
if (-not $IsLinux) {
    throw (
        "SmbShare.Linux cannot be loaded on Windows. " +
        "On Windows, use the built-in 'SmbShare' module: Import-Module SmbShare`n" +
        "SmbShare.Linux is a Linux-only peer module that wraps smbstatus, nfsstat, and /etc/nfs.conf."
    )
}

Get-ChildItem -Path "$PSScriptRoot\Functions" -Filter '*.ps1' |
    Where-Object { $_.Name -notlike '*.Tests.ps1' } |
    ForEach-Object { . $_.FullName }
