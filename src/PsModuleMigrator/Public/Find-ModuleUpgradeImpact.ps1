<#
.SYNOPSIS
Provides the `Find-ModuleUpgradeImpact` public command implementation.

.DESCRIPTION
Contains repository PowerShell logic for `src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1`.
#>


<#

.SYNOPSIS

Finds Module upgrade impact.


.DESCRIPTION

Provides comment-based help for `Find-ModuleUpgradeImpact`.


.PARAMETER ModuleName

Specifies the `ModuleName` value.


.PARAMETER Path

Specifies the `Path` value.


.PARAMETER TargetVersion

Specifies the `TargetVersion` value.

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
