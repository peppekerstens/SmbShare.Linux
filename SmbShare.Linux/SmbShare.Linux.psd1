#
# Module manifest for module 'SmbShare.Linux'
#

@{
    RootModule        = 'SmbShare.Linux.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '3d906a2c-3b6c-4247-aa86-ebd1f1c1dc49'
    Author            = 'Peppe Kerstens'
    CompanyName       = ''
    Copyright         = '(c) Peppe Kerstens. GPL-3.0 license.'
    Description       = 'PowerShell module for Linux providing SMB/NFS cmdlet parity. Get-SmbConnection wraps smbstatus; Get-NfsSession reads /proc/net/rpc/nfs or nfsstat; Get-NfsClientConfiguration reads /etc/nfs.conf and /etc/fstab.'
    PowerShellVersion = '7.2'
    RequiredModules   = @()

    FunctionsToExport = @(
        'Get-NfsClientConfiguration',
        'Get-NfsSession',
        'Get-SmbConnection'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Linux', 'SMB', 'NFS', 'Samba', 'SmbShare', 'CrossPlatform')
            LicenseUri   = 'https://github.com/peppekerstens/SmbShare.Linux/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/peppekerstens/SmbShare.Linux'
            ReleaseNotes = @'
0.1.0 - Initial release. Get-SmbConnection (smbstatus -b), Get-NfsSession (/proc/net/rpc/nfs + nfsstat fallback), Get-NfsClientConfiguration (/etc/nfs.conf + /etc/fstab NFS mounts).
'@
        }
    }
}
