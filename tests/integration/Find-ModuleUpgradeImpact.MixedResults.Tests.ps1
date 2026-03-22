Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Find-ModuleUpgradeImpact mixed-results regression coverage' {
    BeforeAll {
        Import-TestModule
        $folderPath = Get-FixturePath 'projects/folder-sample'
    }

    It 'keeps unaffected files out of the affected file count' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $folderPath -TargetVersion '5.0.0'

        $result.Status | Should -Be 'CompletedWithFindings'
        $result.AffectedFileCount | Should -Be 1
        $result.FindingCount | Should -Be 1
        @($result.Findings | Select-Object -ExpandProperty FilePath -Unique) | Should -Be @((Get-FixturePath 'projects/folder-sample/Compatible.ps1'))
    }
}
