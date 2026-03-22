Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Find-ModuleUpgradeImpact explicit version integration' {
    BeforeAll {
        Import-TestModule
        $sampleFile = Get-FixturePath 'projects/single-file/sample.ps1'
        $invalidVersion = (Get-Content -LiteralPath (Get-FixturePath 'modules/Az.Storage/invalid-version.txt') -Raw).Trim()
    }

    It 'uses the requested target version instead of the default version' {
        $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion '4.1.0'

        $result.ResolvedTargetVersion | Should -Be '4.1.0'
        $result.BaselineVersion | Should -Be '4.0.0'
        $result.FindingCount | Should -Be 2
        @($result.Findings.ChangeType | Select-Object -Unique) | Should -Be @('MandatoryParameterAdded')
        @($result.Findings.ParameterName | Select-Object -Unique) | Should -Be @('Context')
    }

    It 'surfaces invalid explicit versions clearly' {
        try {
            Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion $invalidVersion
            throw 'Expected invalid target version to fail.'
        }
        catch {
            $_.FullyQualifiedErrorId | Should -Match 'InvalidTargetVersion'
        }
    }
}
