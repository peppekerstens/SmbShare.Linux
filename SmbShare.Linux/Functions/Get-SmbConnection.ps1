function Get-SmbConnection {
    <#
    .Synopsis
        Gets the SMB connections established from the local computer.
    .Description
        On Linux, wraps 'smbstatus -b' (brief mode) to list active SMB connections.
        Requires Samba (smbstatus). If Samba is not installed, an error is emitted.
        Returns PSCustomObjects with ServerName, ShareName, UserName, and Dialect properties.
    .Parameter ServerName
        Filter connections by server name. Defaults to '*' (all).
    .Link
        https://learn.microsoft.com/powershell/module/smbshare/get-smbconnection
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0)]
        [string]$ServerName = '*'
    )
    process {
        if (-not (Get-Command smbstatus -ErrorAction SilentlyContinue)) {
            Write-Error 'Get-SmbConnection: smbstatus not found. Install Samba (sudo apt install samba).'
            return
        }
        # smbstatus -b output: PID   Username     Group        Machine         Protocol Version  Encryption  Signing
        # Connections section starts after "Samba version" header
        $raw = & smbstatus -b 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Get-SmbConnection: smbstatus failed: $raw"
            return
        }
        $inConnections = $false
        foreach ($line in $raw) {
            if ($line -match '^-{3,}') { $inConnections = $true; continue }
            if (-not $inConnections) { continue }
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            $cols = $line -split '\s{2,}'
            if ($cols.Count -lt 4) { continue }
            $server = $cols[3].Trim()
            if ($ServerName -ne '*' -and $server -notlike $ServerName) { continue }
            [PSCustomObject]@{
                ServerName   = $server
                UserName     = $cols[1].Trim()
                Dialect      = if ($cols.Count -gt 4) { $cols[4].Trim() } else { 'Unknown' }
                Encryption   = if ($cols.Count -gt 6) { $cols[6].Trim() } else { 'Unknown' }
            }
        }
    }
}
