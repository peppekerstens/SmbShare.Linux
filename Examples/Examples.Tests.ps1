#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }
<#
.Synopsis
    Pester tests for SmbShare.Linux example scripts and scenarios.
.Description
    Validates that the module's cmdlets behave correctly.
    Linux-only and tool-conditional tests are guarded appropriately.
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Run with: Invoke-Pester .\Examples.Tests.ps1 -Output Detailed
#>

BeforeDiscovery {
    $script:smbstatusAvailable = [bool](Get-Command smbstatus -ErrorAction SilentlyContinue)
    $script:nfsProcAvailable   = Test-Path '/proc/net/rpc/nfs'
    $script:nfsconfAvailable   = Test-Path '/etc/nfs.conf'
}

Describe 'Examples: SmbShare.Linux' {
    BeforeAll {
        $script:examplesPath = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $PSCommandPath -Parent }
        $script:moduleRoot   = Split-Path $script:examplesPath -Parent
        $script:modulePath   = Join-Path $script:moduleRoot 'SmbShare.Linux' 'SmbShare.Linux.psd1'
        if ($IsLinux) {
            Import-Module $script:modulePath -Force -ErrorAction Stop
        }
    }
    AfterAll {
        if ($IsLinux) {
            Remove-Module 'SmbShare.Linux' -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'Get-SmbConnection (requires smbstatus)' -Skip:(-not ($IsLinux -and $script:smbstatusAvailable)) {
        It 'returns array or empty without error' {
            { $c = Get-SmbConnection } | Should -Not -Throw
        }
    }

    Context 'Get-NfsSession (requires /proc/net/rpc/nfs)' -Skip:(-not ($IsLinux -and $script:nfsProcAvailable)) {
        It 'returns array or empty without error' {
            { $s = Get-NfsSession } | Should -Not -Throw
        }
    }

    Context 'Get-NfsClientConfiguration (requires /etc/nfs.conf or /etc/fstab)' -Skip:(-not $IsLinux) {
        It 'returns result without error' {
            { $c = Get-NfsClientConfiguration } | Should -Not -Throw
        }
    }
}
