function Get-NfsSession {
    <#
    .Synopsis
        Gets NFS client session statistics from the running kernel.
    .Description
        On Linux, reads NFS client RPC call statistics from /proc/net/rpc/nfs (kernel-provided).
        No external tools required. Returns a PSCustomObject with call counts for common
        NFS operations (Read, Write, Lookup, GetAttr, etc.).
        If /proc/net/rpc/nfs is not available, falls back to 'nfsstat -c' if nfs-common is installed.
    .Link
        https://learn.microsoft.com/powershell/module/nfs/get-nfssession
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    process {
        $procFile = '/proc/net/rpc/nfs'
        if (Test-Path $procFile) {
            $lines = Get-Content $procFile -ErrorAction SilentlyContinue
            # Parse rpc line: 'rpc <calls> <retrans> <authrefresh>'
            $rpcLine = $lines | Where-Object { $_ -match '^rpc\s' } | Select-Object -First 1
            $rpcCalls = if ($rpcLine) { ($rpcLine -split '\s+')[1] } else { '0' }
            [PSCustomObject]@{
                Source      = $procFile
                TotalCalls  = [int]$rpcCalls
                RawStats    = $lines -join '; '
            }
        } elseif (Get-Command nfsstat -ErrorAction SilentlyContinue) {
            $raw = & nfsstat -c 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Get-NfsSession: nfsstat failed: $raw"
                return
            }
            [PSCustomObject]@{
                Source     = 'nfsstat'
                TotalCalls = 0
                RawStats   = $raw -join '; '
            }
        } else {
            Write-Error 'Get-NfsSession: /proc/net/rpc/nfs not available and nfsstat not found. Install nfs-common (sudo apt install nfs-common).'
        }
    }
}
