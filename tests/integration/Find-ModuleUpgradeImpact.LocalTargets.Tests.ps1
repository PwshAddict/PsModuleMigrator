<#
.SYNOPSIS
Provides the PowerShell logic in `tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1`.
#>


Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Find-ModuleUpgradeImpact local target integration' {
    BeforeAll {
        Import-TestModule
        $sampleFile = Get-FixturePath 'projects/single-file/sample.ps1'
        $folderPath = Get-FixturePath 'projects/folder-sample'
    }

    It 'reports the expected findings for a single file upgrade analysis' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion '5.0.0'

                $result.FindingCount | Should -Be 5
                @($result.Findings.ChangeType) | Should -Contain 'RemovedCommand'
                @($result.Findings.ChangeType) | Should -Contain 'RemovedAlias'
                @($result.Findings.ChangeType) | Should -Contain 'RemovedParameter'
            }

            It 'reports only the affected file when scanning a folder' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $folderPath -TargetVersion '5.0.0'

        $result.Status | Should -Be 'CompletedWithFindings'
        $result.FindingCount | Should -Be 1
        $result.AffectedFileCount | Should -Be 1
        $result.Findings[0].FilePath | Should -Match 'Compatible.ps1'
                $result.Findings[0].ChangeType | Should -Be 'RemovedParameter'
            }
        }
