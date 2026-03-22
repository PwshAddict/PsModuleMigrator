Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Local analysis helpers' {
    BeforeAll {
        Import-TestModule
        $sampleFile = Get-FixturePath 'projects/single-file/sample.ps1'
        $noUsageFile = Get-FixturePath 'projects/folder-sample/Invoke-Sample.ps1'
        $folderPath = Get-FixturePath 'projects/folder-sample'
    }

    It 'discovers file and folder targets' {
        InModuleScope PsModuleMigrator -Parameters @{
            sampleFile = $sampleFile
            folderPath = $folderPath
        } {
            $fileTarget = Get-AnalysisTargetFiles -Path $sampleFile
            $folderTarget = Get-AnalysisTargetFiles -Path $folderPath

            $fileTarget.TargetKind | Should -Be 'File'
            $fileTarget.FilePaths | Should -HaveCount 1
            $fileTarget.FilePaths[0] | Should -Be $sampleFile
            $folderTarget.TargetKind | Should -Be 'Folder'
            $folderTarget.FilePaths | Should -Contain (Get-FixturePath 'projects/folder-sample/Compatible.ps1')
            $folderTarget.FilePaths | Should -Contain (Get-FixturePath 'projects/folder-sample/Invoke-Sample.ps1')
        }
    }

    It 'finds local breaking change usages and ignores no-usage scripts' {
        InModuleScope PsModuleMigrator -Parameters @{
            sampleFile = $sampleFile
            noUsageFile = $noUsageFile
        } {
            $context = Resolve-ModuleVersionContext -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion '5.0.0'
            $baselineSurface = Export-ModuleSurface -ModuleName 'Az.Storage' -ModulePath $context.BaselineModulePath -ModuleVersion $context.BaselineVersion
            $targetSurface = Export-ModuleSurface -ModuleName 'Az.Storage' -ModulePath $context.TargetModulePath -ModuleVersion $context.ResolvedTargetVersion
            $descriptors = Compare-ModuleSurface -BaselineSurface $baselineSurface -TargetSurface $targetSurface -BaselineVersion $context.BaselineVersion -TargetVersion $context.ResolvedTargetVersion

            $sampleFindings = Find-CodebaseModuleUsage -ModuleName 'Az.Storage' -FilePaths @($sampleFile) -BreakingChangeDescriptors $descriptors -TargetSurface $targetSurface -RequestId $context.RequestId
            $noUsageFindings = Find-CodebaseModuleUsage -ModuleName 'Az.Storage' -FilePaths @($noUsageFile) -BreakingChangeDescriptors $descriptors -TargetSurface $targetSurface -RequestId $context.RequestId

            $sampleFindings | Should -HaveCount 5
            @($sampleFindings.ChangeType) | Should -Contain 'RemovedCommand'
            @($sampleFindings.ChangeType) | Should -Contain 'RemovedAlias'
            @($sampleFindings.ChangeType) | Should -Contain 'RemovedParameter'
            @($noUsageFindings).Count | Should -Be 0
        }
    }
}
