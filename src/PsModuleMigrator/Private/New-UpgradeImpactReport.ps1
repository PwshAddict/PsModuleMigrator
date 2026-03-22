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
