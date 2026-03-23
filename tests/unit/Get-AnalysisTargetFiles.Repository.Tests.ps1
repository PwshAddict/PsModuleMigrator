<#
.SYNOPSIS
Provides the PowerShell logic in `tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1`.
#>


Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Repository target discovery' {
    BeforeAll {
        Import-TestModule
        $repositoryPath = Initialize-FixtureRepository -RepositoryPath (Get-FixturePath 'repositories/sample-repo')
    }

    It 'enumerates tracked PowerShell files from a git repository' {
        InModuleScope PsModuleMigrator -Parameters @{ repositoryPath = $repositoryPath } {
            $target = Get-AnalysisTargetFiles -Path $repositoryPath

            $target.TargetKind | Should -Be 'Repository'
            $target.FilePaths | Should -HaveCount 2
            $target.FilePaths | Should -Contain (Join-Path $repositoryPath 'src/Invoke-RepoSample.ps1')
            $target.FilePaths | Should -Contain (Join-Path $repositoryPath 'src/NoUsage.ps1')
            @($target.Warnings).Count | Should -Be 0
        }
    }
}
