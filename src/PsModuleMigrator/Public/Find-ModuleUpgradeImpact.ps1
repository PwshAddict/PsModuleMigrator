<#
.SYNOPSIS
Analyzes a PowerShell codebase for breaking changes introduced by a module upgrade.

.DESCRIPTION
Identifies which commands, parameters, and aliases in your scripts will be affected
when upgrading a PowerShell module from one version to another. The function:

  1. Resolves the baseline and target module versions (from fixtures, installed modules,
     or PSResourceGet).
  2. Exports the public surface of both versions in isolated child processes.
  3. Compares the surfaces to produce breaking-change descriptors (removed commands,
     removed parameters, newly mandatory parameters, removed aliases).
  4. Scans the target path (file, folder, or git repository) using the PowerShell AST
     and matches every command invocation against the descriptors.
  5. Returns a structured report with per-finding detail and remediation guidance.

.PARAMETER ModuleName
The name of the PowerShell module to analyze (e.g. "Az.Storage").

.PARAMETER Path
The file, folder, or git repository root to scan for module usage.

.PARAMETER TargetVersion
Optional. The specific module version to treat as the upgrade target. When omitted,
the highest available version is used as the target and the next-lower version as
the baseline.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
Find-ModuleUpgradeImpact -ModuleName Az.Storage -Path ./src

.EXAMPLE
Find-ModuleUpgradeImpact -ModuleName Az.Storage -Path ./src -TargetVersion 5.0.0
#>


function Find-ModuleUpgradeImpact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$TargetVersion
    )

    $startedAt = Get-Date

    try {
        $versionContext = Resolve-ModuleVersionContext -ModuleName $ModuleName -Path $Path -TargetVersion $TargetVersion
        $targetInfo = Get-AnalysisTargetFiles -Path $versionContext.TargetPath
        $baselineSurface = Export-ModuleSurface -ModuleName $ModuleName -ModulePath $versionContext.BaselineModulePath -ModuleVersion $versionContext.BaselineVersion
        $targetSurface = Export-ModuleSurface -ModuleName $ModuleName -ModulePath $versionContext.TargetModulePath -ModuleVersion $versionContext.ResolvedTargetVersion
        $descriptors = Compare-ModuleSurface -BaselineSurface $baselineSurface -TargetSurface $targetSurface -BaselineVersion $versionContext.BaselineVersion -TargetVersion $versionContext.ResolvedTargetVersion

        $analysisRequest = New-AnalysisRequest                     -RequestId $versionContext.RequestId                     -ModuleName $versionContext.ModuleName                     -TargetKind $targetInfo.TargetKind                     -TargetPath $versionContext.TargetPath                     -ResolvedTargetVersion $versionContext.ResolvedTargetVersion                     -BaselineVersion $versionContext.BaselineVersion                     -TargetVersion $versionContext.RequestedTargetVersion                     -RequestedAtUtc $versionContext.RequestedAtUtc

        $findings = if ($targetInfo.FilePaths.Count -gt 0) {
            @(Find-CodebaseModuleUsage -ModuleName $ModuleName -FilePaths $targetInfo.FilePaths -BreakingChangeDescriptors $descriptors -TargetSurface $targetSurface -RequestId $analysisRequest.RequestId)
        }
        else {
            @()
        }

        $duration = [int][Math]::Round(((Get-Date) - $startedAt).TotalMilliseconds)
        return New-UpgradeImpactReport -AnalysisRequest $analysisRequest -Findings $findings -Warnings $targetInfo.Warnings -DurationMs $duration
    }
    catch {
        $exception = $_.Exception
        if ((-not $exception.Data.Contains('ErrorId')) -and $exception.InnerException -and $exception.InnerException.Data.Contains('ErrorId')) {
            $exception = $exception.InnerException
        }

        if (-not $exception.Data.Contains('ErrorId')) {
            $exception = New-PsModuleMigratorException -Message $exception.Message -ErrorId 'AnalysisFailed' -Category 'InvalidOperation'
        }

        $PSCmdlet.ThrowTerminatingError((New-PsModuleMigratorErrorRecord -Exception $exception -TargetObject $Path))
    }
}
