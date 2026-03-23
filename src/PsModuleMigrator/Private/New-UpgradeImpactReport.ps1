<#
.SYNOPSIS
Constructs the analysis request metadata object passed through the pipeline.

.DESCRIPTION
Builds a PSCustomObject that captures the correlated request identity, module
name, resolved version pair, target path kind, and timestamp. This object is
passed to New-UpgradeImpactReport to anchor the final report.

.PARAMETER RequestId
The correlation GUID for this analysis run.

.PARAMETER ModuleName
The PowerShell module name being analyzed.

.PARAMETER TargetKind
How the analysis target was classified: 'File', 'Folder', or 'Repository'.

.PARAMETER TargetPath
The resolved absolute path that was analyzed.

.PARAMETER ResolvedTargetVersion
The version string of the target module (highest or explicitly requested).

.PARAMETER BaselineVersion
The version string of the baseline module (the next-lower discovered version).

.PARAMETER TargetVersion
The raw version string supplied by the caller, if any.

.PARAMETER RequestedAtUtc
The UTC timestamp when the analysis was initiated.

.OUTPUTS
System.Management.Automation.PSCustomObject
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
Creates a single breaking-change finding from a descriptor and a source reference.

.DESCRIPTION
Combines a breaking-change descriptor (from Compare-ModuleSurface) with an AST
source reference (file path, line, column, source text) into a structured finding
object. Attaches a stable FindingId composed of change type, file name, line number,
and command name.

.PARAMETER RequestId
The correlation GUID for the containing analysis run.

.PARAMETER Descriptor
The breaking-change descriptor produced by Compare-ModuleSurface.

.PARAMETER Reference
The source location where the affected command invocation was found.

.PARAMETER Confidence
'High' when the match is definitive; 'Medium' for heuristic matches.

.OUTPUTS
System.Management.Automation.PSCustomObject
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
Assembles the final upgrade impact report returned to the caller.

.DESCRIPTION
Combines the analysis request metadata, all collected findings, any warnings
emitted during analysis, and the elapsed duration into the PSCustomObject
returned by Find-ModuleUpgradeImpact. Sets Status to 'CompletedWithFindings'
or 'CompletedWithoutFindings' based on finding count.

.PARAMETER AnalysisRequest
The request metadata object produced by New-AnalysisRequest.

.PARAMETER Findings
The array of finding objects produced by Find-CodebaseModuleUsage. Defaults to empty.

.PARAMETER Warnings
Any non-fatal warning strings collected during analysis. Defaults to empty.

.PARAMETER DurationMs
Total elapsed milliseconds for the analysis run.

.OUTPUTS
System.Management.Automation.PSCustomObject
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
