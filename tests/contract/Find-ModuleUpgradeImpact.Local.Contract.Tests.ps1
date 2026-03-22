Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Find-ModuleUpgradeImpact local contract' {
    BeforeAll {
        Import-TestModule
        $sampleFile = Get-FixturePath 'projects/single-file/sample.ps1'
        $noUsageFile = Get-FixturePath 'projects/folder-sample/Invoke-Sample.ps1'
    }

    It 'returns the documented object shape for local file analysis' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion '5.0.0'

        $result.RequestId | Should -BeOfType ([guid])
        $result.ModuleName | Should -Be 'Az.Storage'
        $result.TargetKind | Should -Be 'File'
        $result.TargetPath | Should -Be $sampleFile
        $result.ResolvedTargetVersion | Should -Be '5.0.0'
        $result.BaselineVersion | Should -Be '4.1.0'
        $result.Status | Should -Be 'CompletedWithFindings'
        $result.Findings | Should -Not -BeNullOrEmpty
        @($result.Warnings).Count | Should -Be 0
        ($result.DurationMs -ge 0) | Should -BeTrue
    }

    It 'returns a no-findings result when the file has no relevant usage' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $noUsageFile -TargetVersion '5.0.0'

        $result.Status | Should -Be 'CompletedWithoutFindings'
        $result.FindingCount | Should -Be 0
        $result.AffectedFileCount | Should -Be 0
        @($result.Findings).Count | Should -Be 0
    }
}
