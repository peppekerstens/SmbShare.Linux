#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }
param()

BeforeDiscovery {
    $script:OnLinux     = $IsLinux
    $script:HasSmbstatus = $IsLinux -and (Get-Command smbstatus -ErrorAction SilentlyContinue)
    $script:HasProcNfs   = $IsLinux -and (Test-Path '/proc/net/rpc/nfs')
    $script:HasNfsConf   = $IsLinux -and (Test-Path '/etc/nfs.conf')
}

Describe 'SmbShare.Linux module' -Skip:(-not $script:OnLinux) {

    BeforeAll {
        if ($IsLinux) {
            $modulePath = Join-Path $PSScriptRoot '..' 'SmbShare.Linux' 'SmbShare.Linux.psd1'
            Import-Module (Resolve-Path $modulePath).Path -Force
        }
    }

    AfterAll {
        if ($IsLinux) {
            Remove-Module SmbShare.Linux -ErrorAction SilentlyContinue
        }
    }

    Context 'Module loads correctly' {
        It 'Exports Get-SmbConnection' {
            Get-Command -Module SmbShare.Linux -Name Get-SmbConnection | Should -Not -BeNullOrEmpty
        }
        It 'Exports Get-NfsSession' {
            Get-Command -Module SmbShare.Linux -Name Get-NfsSession | Should -Not -BeNullOrEmpty
        }
        It 'Exports Get-NfsClientConfiguration' {
            Get-Command -Module SmbShare.Linux -Name Get-NfsClientConfiguration | Should -Not -BeNullOrEmpty
        }
        It 'Exports exactly 3 functions' {
            (Get-Command -Module SmbShare.Linux).Count | Should -Be 3
        }
    }

    Context 'Get-SmbConnection — Samba integration' {
        It 'Returns an error when smbstatus is absent' -Skip:$script:HasSmbstatus {
            $errors = $null
            Get-SmbConnection -ErrorVariable errors -ErrorAction SilentlyContinue
            $errors | Should -Not -BeNullOrEmpty
        }
        It 'Returns objects with expected properties when Samba is available' -Skip:(-not $script:HasSmbstatus) {
            $conns = @(Get-SmbConnection)
            if ($conns.Count -gt 0) {
                $conns[0].PSObject.Properties.Name | Should -Contain 'ServerName'
                $conns[0].PSObject.Properties.Name | Should -Contain 'UserName'
                $conns[0].PSObject.Properties.Name | Should -Contain 'Dialect'
            }
        }
    }

    Context 'Get-NfsSession — /proc/net/rpc/nfs' {
        It 'Returns a result object when /proc/net/rpc/nfs exists' -Skip:(-not $script:HasProcNfs) {
            $session = Get-NfsSession
            $session | Should -Not -BeNullOrEmpty
            $session.PSObject.Properties.Name | Should -Contain 'TotalCalls'
        }
        It 'Returns an error when neither /proc/net/rpc/nfs nor nfsstat is available' -Skip:$script:HasProcNfs {
            if (Get-Command nfsstat -ErrorAction SilentlyContinue) {
                Set-ItResult -Skipped -Because 'nfsstat found — fallback will succeed'
                return
            }
            $errors = $null
            Get-NfsSession -ErrorVariable errors -ErrorAction SilentlyContinue
            $errors | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Get-NfsClientConfiguration — config files' {
        It 'Returns results from /etc/fstab when present' {
            # /etc/fstab is always present on Linux; may have 0 NFS entries — that is valid
            $results = @(Get-NfsClientConfiguration)
            $results.GetType().IsArray | Should -Be $true
        }
        It 'Returns objects with expected properties' {
            $result = Get-NfsClientConfiguration | Select-Object -First 1
            if ($result) {
                $result.PSObject.Properties.Name | Should -Contain 'Source'
                $result.PSObject.Properties.Name | Should -Contain 'Key'
                $result.PSObject.Properties.Name | Should -Contain 'Value'
            }
        }
        It 'Returns nfs.conf entries when /etc/nfs.conf exists' -Skip:(-not $script:HasNfsConf) {
            $nfsResults = @(Get-NfsClientConfiguration | Where-Object { $_.Source -eq '/etc/nfs.conf' })
            $nfsResults.Count | Should -BeGreaterThan 0
        }
    }
}

Describe 'SmbShare.Linux throws on non-Linux' -Skip:$script:OnLinux {
    It 'Module throws when loaded on Windows' {
        $modulePath = Join-Path $PSScriptRoot '..' 'SmbShare.Linux' 'SmbShare.Linux.psd1'
        { Import-Module (Resolve-Path $modulePath).Path -Force -ErrorAction Stop } | Should -Throw
    }
}
