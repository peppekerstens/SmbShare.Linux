function Get-NfsClientConfiguration {
    <#
    .Synopsis
        Gets the NFS client configuration from /etc/nfs.conf and /etc/fstab NFS mounts.
    .Description
        On Linux, reads /etc/nfs.conf for NFS daemon settings and /etc/fstab for
        configured NFS mount points. Returns PSCustomObjects with configuration entries.
        If /etc/nfs.conf is absent (nfs-common not installed), only fstab NFS mounts are returned.
    .Link
        https://learn.microsoft.com/powershell/module/nfs/get-nfsclientconfiguration
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    process {
        # Read /etc/nfs.conf if present
        $nfsConf = '/etc/nfs.conf'
        if (Test-Path $nfsConf) {
            $lines = Get-Content $nfsConf -ErrorAction SilentlyContinue
            $section = 'global'
            foreach ($line in $lines) {
                $trimmed = $line.Trim()
                if ($trimmed -match '^\[(.+)\]$') { $section = $Matches[1]; continue }
                if ($trimmed -match '^#' -or [string]::IsNullOrWhiteSpace($trimmed)) { continue }
                if ($trimmed -match '^([^=]+)=(.*)$') {
                    [PSCustomObject]@{
                        Source    = $nfsConf
                        Section   = $section
                        Key       = $Matches[1].Trim()
                        Value     = $Matches[2].Trim()
                    }
                }
            }
        } else {
            Write-Verbose 'Get-NfsClientConfiguration: /etc/nfs.conf not found; reading fstab NFS mounts only.'
        }

        # Read NFS entries from /etc/fstab
        $fstab = '/etc/fstab'
        if (Test-Path $fstab) {
            $lines = Get-Content $fstab -ErrorAction SilentlyContinue
            foreach ($line in $lines) {
                $trimmed = $line.Trim()
                if ($trimmed -match '^#' -or [string]::IsNullOrWhiteSpace($trimmed)) { continue }
                $cols = $trimmed -split '\s+'
                if ($cols.Count -lt 4) { continue }
                $fsType = $cols[2]
                if ($fsType -notin @('nfs', 'nfs4')) { continue }
                [PSCustomObject]@{
                    Source    = $fstab
                    Section   = 'fstab'
                    Key       = $cols[1]   # Mount point
                    Value     = "$($cols[0]) ($fsType) opts=$($cols[3])"
                }
            }
        }
    }
}
