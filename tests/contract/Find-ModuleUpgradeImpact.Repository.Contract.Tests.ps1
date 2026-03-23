<#
.SYNOPSIS
Provides the PowerShell logic in `tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1`.
#>


Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Find-ModuleUpgradeImpact repository contract' {
    BeforeAll {
        Import-TestModule
        $repositoryPath = Initialize-FixtureRepository -RepositoryPath (Get-FixturePath 'repositories/sample-repo')
    }

    It 'returns repository-target results with file-scoped findings' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $repositoryPath -TargetVersion '5.0.0'

        $result.TargetKind | Should -Be 'Repository'
        $result.Status | Should -Be 'CompletedWithFindings'
        $result.AffectedFileCount | Should -Be 1
        (@($result.Findings | Select-Object -ExpandProperty FilePath -Unique)).Count | Should -Be 1
        $result.Findings[0].FilePath | Should -Match 'Invoke-RepoSample.ps1'
    }
}
