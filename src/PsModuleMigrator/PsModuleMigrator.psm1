Set-StrictMode -Version 3.0

$script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
<#
.SYNOPSIS
Returns the repository root directory two levels above the module root.
#>


function Get-PsModuleMigratorRepositoryRoot {
    [CmdletBinding()]
    param()

    return Split-Path -Parent (Split-Path -Parent $script:ModuleRoot)
}
<#
.SYNOPSIS
Resolves a path string to its absolute, canonical form using Get-Item.

.PARAMETER Path
The path string to normalize. Throws if the path does not exist.
#>
function ConvertTo-NormalizedPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $item = Get-Item -LiteralPath $Path -ErrorAction Stop
    return $item.FullName
}
<#
.SYNOPSIS
Creates a typed exception carrying PsModuleMigrator error metadata.

.DESCRIPTION
Wraps the message in an InvalidOperationException and stamps ErrorId and
Category into the exception's Data dictionary so callers can distinguish
module-thrown errors from unexpected runtime exceptions.

.PARAMETER Message
The human-readable error message.

.PARAMETER ErrorId
A short camelCase identifier for the error (e.g. 'InvalidTargetVersion').

.PARAMETER Category
The ErrorCategory name string. Defaults to 'InvalidOperation'.
#>
function New-PsModuleMigratorException {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [string]$ErrorId,

        [Parameter()]
        [string]$Category = 'InvalidOperation'
    )

    $exception = [System.InvalidOperationException]::new($Message)
    $exception.Data['ErrorId'] = $ErrorId
    $exception.Data['Category'] = $Category
    return $exception
}
<#
.SYNOPSIS
Builds an ErrorRecord from a PsModuleMigrator exception for use with ThrowTerminatingError.

.PARAMETER Exception
The exception produced by New-PsModuleMigratorException.

.PARAMETER TargetObject
The object being processed when the error occurred (attached to the ErrorRecord).
#>
function New-PsModuleMigratorErrorRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Exception]$Exception,

        [Parameter()]
        [object]$TargetObject
    )

    $errorId = if ($Exception.Data.Contains('ErrorId')) { [string]$Exception.Data['ErrorId'] } else { 'AnalysisFailed' }
    $categoryName = if ($Exception.Data.Contains('Category')) { [string]$Exception.Data['Category'] } else { 'InvalidOperation' }

    try {
        $category = [System.Enum]::Parse([System.Management.Automation.ErrorCategory], $categoryName)
    }
    catch {
        $category = [System.Management.Automation.ErrorCategory]::InvalidOperation
    }

    return [System.Management.Automation.ErrorRecord]::new($Exception, $errorId, $category, $TargetObject)
}

$privateScripts = Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Private') -Filter '*.ps1' -File | Sort-Object Name
foreach ($scriptFile in $privateScripts) {
    . $scriptFile.FullName
}

$publicScripts = Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public') -Filter '*.ps1' -File | Sort-Object Name
foreach ($scriptFile in $publicScripts) {
    . $scriptFile.FullName
}

Export-ModuleMember -Function 'Find-ModuleUpgradeImpact'
