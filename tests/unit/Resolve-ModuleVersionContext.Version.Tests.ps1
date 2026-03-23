<#
.SYNOPSIS
Provides the PowerShell logic in `tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1`.
#>


Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Version resolution and surface comparison' {
    BeforeAll {
        Import-TestModule
        $sampleFile = Get-FixturePath 'projects/single-file/sample.ps1'
    }

    It 'resolves an explicit fixture version and exports comparable surfaces' {
        InModuleScope PsModuleMigrator -Parameters @{ sampleFile = $sampleFile } {
            $context = Resolve-ModuleVersionContext -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion '4.1.0'
            $baselineSurface = Export-ModuleSurface -ModuleName 'Az.Storage' -ModulePath $context.BaselineModulePath -ModuleVersion $context.BaselineVersion
            $targetSurface = Export-ModuleSurface -ModuleName 'Az.Storage' -ModulePath $context.TargetModulePath -ModuleVersion $context.ResolvedTargetVersion
            $descriptors = Compare-ModuleSurface -BaselineSurface $baselineSurface -TargetSurface $targetSurface -BaselineVersion $context.BaselineVersion -TargetVersion $context.ResolvedTargetVersion

            $context.ResolvedTargetVersion | Should -Be '4.1.0'
            $context.BaselineVersion | Should -Be '4.0.0'
            @($descriptors.ChangeType) | Should -Contain 'MandatoryParameterAdded'
            ($descriptors | Where-Object { $_.ParameterName -eq 'Context' }).Count | Should -Be 1
        }
    }

    It 'fails invalid target versions clearly' {
        InModuleScope PsModuleMigrator -Parameters @{ sampleFile = $sampleFile } {
            { Resolve-ModuleVersionContext -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion '9.9.9' } | Should -Throw
        }
    }
}
