Set-StrictMode -Version 3.0

$script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Get-PsModuleMigratorRepositoryRoot {
    [CmdletBinding()]
    param()

    return Split-Path -Parent (Split-Path -Parent $script:ModuleRoot)
}

function ConvertTo-NormalizedPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $item = Get-Item -LiteralPath $Path -ErrorAction Stop
    return $item.FullName
}

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
