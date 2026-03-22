Import-Module (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1') -Force

Describe 'Internal branch coverage' {
    BeforeAll {
        Import-TestModule
        $sampleFile = Get-FixturePath 'projects/single-file/sample.ps1'
        $newTemporaryModuleVersion = {
            param(
                [Parameter(Mandatory)]
                [string]$Root,

                [Parameter(Mandatory)]
                [string]$ModuleName,

                [Parameter(Mandatory)]
                [string]$Version
            )

            $modulePath = Join-Path $Root $ModuleName
            $versionPath = Join-Path $modulePath $Version
            $commandName = 'Get-' + ($ModuleName -replace '[^A-Za-z0-9]', '')
            $null = New-Item -ItemType Directory -Path $versionPath -Force

            Set-Content -LiteralPath (Join-Path $versionPath "$ModuleName.psd1") -Encoding utf8 -Value @"
@{
    RootModule = '$ModuleName.psm1'
    ModuleVersion = '$Version'
    GUID = '$(New-Guid)'
    Author = 'Test'
    PowerShellVersion = '7.4'
    FunctionsToExport = @('$commandName')
}
"@

            Set-Content -LiteralPath (Join-Path $versionPath "$ModuleName.psm1") -Encoding utf8 -Value "function $commandName { [CmdletBinding()] param() }`nExport-ModuleMember -Function $commandName"
            return $versionPath
        }
    }

    It 'covers duplicate parameter merging in Compare-ModuleSurface' {
        InModuleScope PsModuleMigrator {
            $baseline = [PSCustomObject]@{
                ModuleName = 'Baseline.Module'
                Commands = @(
                    [PSCustomObject]@{
                        Name = 'Invoke-BranchCoverage'
                        ParameterSets = @(
                            [PSCustomObject]@{ Name = 'Optional'; Parameters = @([PSCustomObject]@{ Name = 'Name'; IsMandatory = $false }) },
                            [PSCustomObject]@{ Name = 'Mandatory'; Parameters = @([PSCustomObject]@{ Name = 'Name'; IsMandatory = $true }) }
                        )
                    }
                )
                Aliases = @()
            }
            $target = [PSCustomObject]@{
                ModuleName = 'Target.Module'
                Commands = @(
                    [PSCustomObject]@{
                        Name = 'Invoke-BranchCoverage'
                        ParameterSets = @(
                            [PSCustomObject]@{ Name = 'Optional'; Parameters = @([PSCustomObject]@{ Name = 'Name'; IsMandatory = $true }) }
                        )
                    }
                )
                Aliases = @()
            }

            $descriptors = Compare-ModuleSurface -BaselineSurface $baseline -TargetSurface $target -BaselineVersion '1.0.0' -TargetVersion '2.0.0'
            @($descriptors | Where-Object ChangeType -eq 'MandatoryParameterAdded').Count | Should -Be 0
        }
    }

    It 'reports export failures for missing module paths' {
        InModuleScope PsModuleMigrator {
            { Export-ModuleSurface -ModuleName 'Missing.Module' -ModulePath (Join-Path ([System.IO.Path]::GetTempPath()) 'missing-module.psd1') -ModuleVersion '1.0.0' } | Should -Throw
        }
    }

    It 'wraps child process module import failures' {
        $badManifest = Join-Path ([System.IO.Path]::GetTempPath()) ("BadModule-$([guid]::NewGuid().ToString('N')).psd1")
        try {
            Set-Content -LiteralPath $badManifest -Encoding utf8 -Value "@{ RootModule = 'Missing.psm1'; ModuleVersion = '1.0.0'; GUID = '$(New-Guid)' }"
            InModuleScope PsModuleMigrator -Parameters @{ badManifest = $badManifest } {
                { Export-ModuleSurface -ModuleName 'BadModule' -ModulePath $badManifest -ModuleVersion '1.0.0' } | Should -Throw
            }
        }
        finally {
            Remove-Item -LiteralPath $badManifest -Force -ErrorAction SilentlyContinue
        }
    }

    It 'covers invalid target paths, unsupported files, empty folders, and repository fallback' {
        $textFile = Join-Path ([System.IO.Path]::GetTempPath()) ("unsupported-$([guid]::NewGuid().ToString('N')).txt")
        $emptyFolder = Join-Path ([System.IO.Path]::GetTempPath()) ("empty-folder-$([guid]::NewGuid().ToString('N'))")
        $fallbackRepo = Join-Path ([System.IO.Path]::GetTempPath()) ("fake-repo-$([guid]::NewGuid().ToString('N'))")

        try {
            Set-Content -LiteralPath $textFile -Encoding utf8 -Value 'hello'
            $null = New-Item -ItemType Directory -Path $emptyFolder -Force
            $null = New-Item -ItemType Directory -Path (Join-Path $fallbackRepo '.git') -Force
            $null = New-Item -ItemType Directory -Path (Join-Path $fallbackRepo 'src') -Force
            Set-Content -LiteralPath (Join-Path $fallbackRepo 'src/Fallback.ps1') -Encoding utf8 -Value "Get-Date | Out-Null`n"

            InModuleScope PsModuleMigrator -Parameters @{ textFile = $textFile; emptyFolder = $emptyFolder; fallbackRepo = $fallbackRepo } {
                { Get-AnalysisTargetFiles -Path (Join-Path $emptyFolder 'missing.ps1') } | Should -Throw
                { Get-AnalysisTargetFiles -Path $textFile } | Should -Throw

                $emptyTarget = Get-AnalysisTargetFiles -Path $emptyFolder
                $emptyTarget.TargetKind | Should -Be 'Folder'
                @($emptyTarget.Warnings).Count | Should -Be 1

                $fallbackTarget = Get-AnalysisTargetFiles -Path $fallbackRepo
                $fallbackTarget.TargetKind | Should -Be 'Repository'
                $fallbackTarget.FilePaths | Should -HaveCount 1
                @($fallbackTarget.Warnings).Count | Should -Be 1
            }
        }
        finally {
            Remove-Item -LiteralPath $textFile -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $emptyFolder -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $fallbackRepo -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'reports module-qualified commands missing from the target surface' {
        $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) ("missing-target-$([guid]::NewGuid().ToString('N')).ps1")
        try {
            Set-Content -LiteralPath $tempFile -Encoding utf8 -Value "Az.Storage\\Get-FutureThing -Name 'demo'`n"
            InModuleScope PsModuleMigrator -Parameters @{ tempFile = $tempFile } {
                $targetSurface = [PSCustomObject]@{ Commands = @(); Aliases = @() }
                $findings = Find-CodebaseModuleUsage -ModuleName 'Az.Storage' -FilePaths @($tempFile) -BreakingChangeDescriptors @([PSCustomObject]@{ CommandName = 'Placeholder'; ChangeType = 'RemovedCommand' }) -TargetSurface $targetSurface -RequestId ([guid]::NewGuid())

                $findings | Should -HaveCount 1
                $findings[0].ChangeType | Should -Be 'CommandMissingFromTarget'
            }
        }
        finally {
            Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        }
    }

    It 'handles malformed target versions and missing modules without providers' {
        InModuleScope PsModuleMigrator -Parameters @{ sampleFile = $sampleFile } {
            { Resolve-ModuleVersionContext -ModuleName 'Az.Storage' -Path $sampleFile -TargetVersion 'banana' } | Should -Throw

            Mock Get-Module { @() }
            Mock Get-Command { $null }
            { Resolve-ModuleVersionContext -ModuleName 'No.Such.Module' -Path $sampleFile -TargetVersion '1.0.0' } | Should -Throw
        }
    }

    It 'uses installed module metadata when module paths are not populated' {
        $moduleRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("installed-module-$([guid]::NewGuid().ToString('N'))")
        try {
            $v1 = & $newTemporaryModuleVersion -Root $moduleRoot -ModuleName 'Installed.Mock' -Version '1.0.0'
            $v2 = & $newTemporaryModuleVersion -Root $moduleRoot -ModuleName 'Installed.Mock' -Version '2.0.0'
            InModuleScope PsModuleMigrator -Parameters @{ sampleFile = $sampleFile; v1 = $v1; v2 = $v2 } {
                Mock Get-Module {
                    @(
                        [PSCustomObject]@{ Version = [version]'2.0.0'; Path = $null; ModuleBase = $v2 },
                        [PSCustomObject]@{ Version = [version]'1.0.0'; Path = $null; ModuleBase = $v1 }
                    )
                }
                Mock Get-Command { $null }

                $context = Resolve-ModuleVersionContext -ModuleName 'Installed.Mock' -Path $sampleFile -TargetVersion '2.0.0'
                $context.ResolvedTargetVersion | Should -Be '2.0.0'
                $context.BaselineVersion | Should -Be '1.0.0'
                $context.TargetModulePath | Should -Match 'Installed.Mock.psd1'
            }
        }
        finally {
            Remove-Item -LiteralPath $moduleRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'uses mocked PSResourceGet for explicit target version downloads' {
        $cacheRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'PsModuleMigrator/module-cache'
        $moduleCache = Join-Path $cacheRoot 'Remote.Mock'
        Remove-Item -LiteralPath $moduleCache -Recurse -Force -ErrorAction SilentlyContinue
        try {
            InModuleScope PsModuleMigrator -Parameters @{ sampleFile = $sampleFile; cacheRoot = $cacheRoot } {
                Mock Get-Module { @() }
                Mock Get-Command { [PSCustomObject]@{ Name = 'Save-PSResource' } }
                Mock Save-PSResource {
                    foreach ($resolvedVersion in @('2.0.0', '3.0.0')) {
                        $moduleName = 'Remote.Mock'
                        $commandName = 'Get-' + ($moduleName -replace '[^A-Za-z0-9]', '')
                        $modulePath = Join-Path (Join-Path $cacheRoot $moduleName) $resolvedVersion
                        $null = New-Item -ItemType Directory -Path $modulePath -Force
                        Set-Content -LiteralPath (Join-Path $modulePath "$moduleName.psd1") -Encoding utf8 -Value @"
@{
    RootModule = '$moduleName.psm1'
    ModuleVersion = '$resolvedVersion'
    GUID = '$(New-Guid)'
    Author = 'Test'
    PowerShellVersion = '7.4'
    FunctionsToExport = @('$commandName')
}
"@
                        Set-Content -LiteralPath (Join-Path $modulePath "$moduleName.psm1") -Encoding utf8 -Value "function $commandName { [CmdletBinding()] param() }`nExport-ModuleMember -Function $commandName"
                    }
                }

                $context = Resolve-ModuleVersionContext -ModuleName 'Remote.Mock' -Path $sampleFile -TargetVersion '3.0.0'
                $context.ResolvedTargetVersion | Should -Be '3.0.0'
                $context.BaselineVersion | Should -Be '2.0.0'
            }
        }
        finally {
            Remove-Item -LiteralPath $moduleCache -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'uses mocked PSResourceGet for latest target resolution' {
        $cacheRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'PsModuleMigrator/module-cache'
        $moduleCache = Join-Path $cacheRoot 'RemoteLatest.Mock'
        Remove-Item -LiteralPath $moduleCache -Recurse -Force -ErrorAction SilentlyContinue
        try {
            InModuleScope PsModuleMigrator -Parameters @{ sampleFile = $sampleFile; cacheRoot = $cacheRoot } {
                Mock Get-Module { @() }
                Mock Get-Command { [PSCustomObject]@{ Name = 'Save-PSResource' } }
                Mock Find-PSResource {
                    @(
                        [PSCustomObject]@{ Version = [version]'3.0.0' },
                        [PSCustomObject]@{ Version = [version]'2.0.0' }
                    )
                }
                Mock Save-PSResource {
                    $moduleName = 'RemoteLatest.Mock'
                    $resolvedVersion = @('3.0.0', '2.0.0') | Where-Object { -not (Test-Path -LiteralPath (Join-Path (Join-Path $cacheRoot $moduleName) $_)) } | Select-Object -First 1
                    $commandName = 'Get-' + ($moduleName -replace '[^A-Za-z0-9]', '')
                    $modulePath = Join-Path (Join-Path $cacheRoot $moduleName) $resolvedVersion
                    $null = New-Item -ItemType Directory -Path $modulePath -Force
                    Set-Content -LiteralPath (Join-Path $modulePath "$moduleName.psd1") -Encoding utf8 -Value @"
@{
    RootModule = '$moduleName.psm1'
    ModuleVersion = '$resolvedVersion'
    GUID = '$(New-Guid)'
    Author = 'Test'
    PowerShellVersion = '7.4'
    FunctionsToExport = @('$commandName')
}
"@
                    Set-Content -LiteralPath (Join-Path $modulePath "$moduleName.psm1") -Encoding utf8 -Value "function $commandName { [CmdletBinding()] param() }`nExport-ModuleMember -Function $commandName"
                }

                $context = Resolve-ModuleVersionContext -ModuleName 'RemoteLatest.Mock' -Path $sampleFile
                $context.ResolvedTargetVersion | Should -Be '3.0.0'
                $context.BaselineVersion | Should -Be '2.0.0'
            }
        }
        finally {
            Remove-Item -LiteralPath $moduleCache -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'returns no findings for an empty target list through the public command path' {
        $emptyFolder = Join-Path ([System.IO.Path]::GetTempPath()) ("public-empty-folder-$([guid]::NewGuid().ToString('N'))")
        try {
            $null = New-Item -ItemType Directory -Path $emptyFolder -Force
            $result = Find-ModuleUpgradeImpact -ModuleName 'Az.Storage' -Path $emptyFolder -TargetVersion '5.0.0'
            $result.Status | Should -Be 'CompletedWithoutFindings'
            @($result.Warnings).Count | Should -Be 1
        }
        finally {
            Remove-Item -LiteralPath $emptyFolder -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
