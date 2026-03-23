<#
.SYNOPSIS
Loads the PsModuleMigrator module implementation.

.DESCRIPTION
Contains repository PowerShell logic for `src/PsModuleMigrator/PsModuleMigrator.psm1`.
#>


Set-StrictMode -Version 3.0

$script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
<#

.SYNOPSIS

Gets Ps module migrator repository root.


.DESCRIPTION

Provides comment-based help for `Get-PsModuleMigratorRepositoryRoot`.

#>


function Get-PsModuleMigratorRepositoryRoot {
    [CmdletBinding()]
    param()

    return Split-Path -Parent (Split-Path -Parent $script:ModuleRoot)
}
<#

.SYNOPSIS

Converts Normalized path.


.DESCRIPTION

Provides comment-based help for `ConvertTo-NormalizedPath`.


.PARAMETER Path

Specifies the `Path` value.

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

Creates Ps module migrator exception.


.DESCRIPTION

Provides comment-based help for `New-PsModuleMigratorException`.


.PARAMETER Message

Specifies the `Message` value.


.PARAMETER ErrorId

Specifies the `ErrorId` value.


.PARAMETER Category

Specifies the `Category` value.

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

Creates Ps module migrator error record.


.DESCRIPTION

Provides comment-based help for `New-PsModuleMigratorErrorRecord`.


.PARAMETER Exception

Specifies the `Exception` value.


.PARAMETER TargetObject

Specifies the `TargetObject` value.

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
