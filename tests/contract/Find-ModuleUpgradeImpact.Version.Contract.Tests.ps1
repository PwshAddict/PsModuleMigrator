<#
.SYNOPSIS
Provides the PowerShell logic in `tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1`.
#>


Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Find-ModuleUpgradeImpact version contract' {
    BeforeAll {
        Import-TestModule
        $sampleFile = Get-FixturePath 'projects/single-file/sample.ps1'
        $invalidVersion = (Get-Content -LiteralPath (Get-FixturePath 'modules/Az.Storage/invalid-version.txt') -Raw).Trim()
    }

    It 'echoes the explicit target version in the result' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion '4.1.0'

        $result.ResolvedTargetVersion | Should -Be '4.1.0'
        $result.BaselineVersion | Should -Be '4.0.0'
    }

    It 'throws InvalidTargetVersion for unavailable explicit versions' {
        try {
            Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion $invalidVersion
            throw 'Expected Find-ModuleUpgradeImpact to fail.'
        }
        catch {
            $_.FullyQualifiedErrorId | Should -Match 'InvalidTargetVersion'
        }
    }
}
