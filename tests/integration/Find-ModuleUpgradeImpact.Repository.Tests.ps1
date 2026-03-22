Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Find-ModuleUpgradeImpact repository integration' {
    BeforeAll {
        Import-TestModule
        $repositoryPath = Initialize-FixtureRepository -RepositoryPath (Get-FixturePath 'repositories/sample-repo')
    }

    It 'analyzes tracked repository files and returns grouped findings' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $repositoryPath -TargetVersion '5.0.0'

        $result.TargetKind | Should -Be 'Repository'
        $result.FindingCount | Should -Be 1
        @($result.Findings.ChangeType) | Should -Contain 'RemovedAlias'
    }

    It 'returns no findings for a repository with no module usage' {
        $emptyRepo = New-TemporaryPowerShellFixture -Name 'repo-no-usage' -Files @('src/NoUsage.ps1')
        try {
            $repoPath = Initialize-FixtureRepository -RepositoryPath $emptyRepo
            $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $repoPath -TargetVersion '5.0.0'

            $result.Status | Should -Be 'CompletedWithoutFindings'
            $result.FindingCount | Should -Be 0
        }
        finally {
            Remove-Item -LiteralPath $emptyRepo -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
