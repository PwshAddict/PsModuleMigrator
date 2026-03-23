<#
.SYNOPSIS
Provides the `New-UpgradeImpactReport` private helper implementation.

.DESCRIPTION
Contains repository PowerShell logic for `src/PsModuleMigrator/Private/New-UpgradeImpactReport.ps1`.
#>


<#

.SYNOPSIS

Creates Analysis request.


.DESCRIPTION

Provides comment-based help for `New-AnalysisRequest`.


.PARAMETER RequestId

Specifies the `RequestId` value.


.PARAMETER ModuleName

Specifies the `ModuleName` value.


.PARAMETER TargetKind

Specifies the `TargetKind` value.


.PARAMETER TargetPath

Specifies the `TargetPath` value.


.PARAMETER ResolvedTargetVersion

Specifies the `ResolvedTargetVersion` value.


.PARAMETER BaselineVersion

Specifies the `BaselineVersion` value.


.PARAMETER TargetVersion

Specifies the `TargetVersion` value.


.PARAMETER RequestedAtUtc

Specifies the `RequestedAtUtc` value.

#>


function New-AnalysisRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid]$RequestId,

        [Parameter(Mandatory)]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [ValidateSet('File', 'Folder', 'Repository')]
        [string]$TargetKind,

        [Parameter(Mandatory)]
        [string]$TargetPath,

        [Parameter(Mandatory)]
        [string]$ResolvedTargetVersion,

        [Parameter(Mandatory)]
        [string]$BaselineVersion,

        [Parameter()]
        [string]$TargetVersion,

        [Parameter(Mandatory)]
        [datetime]$RequestedAtUtc
    )

    [PSCustomObject]@{
        RequestId              = $RequestId
        ModuleName             = $ModuleName
        TargetKind             = $TargetKind
        TargetPath             = $TargetPath
        TargetVersion          = $TargetVersion
        ResolvedTargetVersion  = $ResolvedTargetVersion
        BaselineVersion        = $BaselineVersion
        RequestedAtUtc         = $RequestedAtUtc
    }
}
<#

.SYNOPSIS

Creates Breaking change finding.


.DESCRIPTION

Provides comment-based help for `New-BreakingChangeFinding`.


.PARAMETER RequestId

Specifies the `RequestId` value.


.PARAMETER Descriptor

Specifies the `Descriptor` value.


.PARAMETER Reference

Specifies the `Reference` value.


.PARAMETER Confidence

Specifies the `Confidence` value.

#>


function New-BreakingChangeFinding {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid]$RequestId,

        [Parameter(Mandatory)]
        [psobject]$Descriptor,

        [Parameter(Mandatory)]
        [psobject]$Reference,

        [Parameter(Mandatory)]
        [ValidateSet('High', 'Medium')]
        [string]$Confidence
    )

    [PSCustomObject]@{
        FindingId            = '{0}:{1}:{2}:{3}' -f $Descriptor.ChangeType, ([System.IO.Path]::GetFileName($Reference.FilePath)), $Reference.LineNumber, $Descriptor.CommandName
        ChangeType           = $Descriptor.ChangeType
        Severity             = $Descriptor.Severity
        CommandName          = $Descriptor.CommandName
        ParameterName        = $Descriptor.ParameterName
        FilePath             = $Reference.FilePath
        LineNumber           = [int]$Reference.LineNumber
        ColumnNumber         = [int]$Reference.ColumnNumber
        SourceText           = $Reference.SourceText
        Confidence           = $Confidence
        Explanation          = $Descriptor.Explanation
        SuggestedRemediation = $Descriptor.SuggestedRemediation
    }
}
<#

.SYNOPSIS

Creates Upgrade impact report.


.DESCRIPTION

Provides comment-based help for `New-UpgradeImpactReport`.


.PARAMETER AnalysisRequest

Specifies the `AnalysisRequest` value.


.PARAMETER Findings

Specifies the `Findings` value.


.PARAMETER Warnings

Specifies the `Warnings` value.


.PARAMETER DurationMs

Specifies the `DurationMs` value.

#>


function New-UpgradeImpactReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$AnalysisRequest,

        [Parameter()]
        [object[]]$Findings = @(),

        [Parameter()]
        [string[]]$Warnings = @(),

        [Parameter(Mandatory)]
        [int]$DurationMs
    )

    $findings = @($Findings | Where-Object { $null -ne $_ })
    $warnings = [string[]]@($Warnings | Where-Object { $_ })
    $status = if ($findings.Count -gt 0) { 'CompletedWithFindings' } else { 'CompletedWithoutFindings' }
    $affectedFileCount = @($findings | Select-Object -ExpandProperty FilePath -Unique).Count

    [PSCustomObject]@{
        RequestId             = $AnalysisRequest.RequestId
        ModuleName            = $AnalysisRequest.ModuleName
        TargetKind            = $AnalysisRequest.TargetKind
        TargetPath            = $AnalysisRequest.TargetPath
        ResolvedTargetVersion = $AnalysisRequest.ResolvedTargetVersion
        BaselineVersion       = $AnalysisRequest.BaselineVersion
        Status                = $status
        FindingCount          = $findings.Count
        AffectedFileCount     = $affectedFileCount
        Findings              = $findings
        Warnings              = $warnings
        DurationMs            = $DurationMs
    }
}
