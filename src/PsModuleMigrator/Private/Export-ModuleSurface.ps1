function Export-ModuleSurface {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [string]$ModulePath,

        [Parameter(Mandatory)]
        [string]$ModuleVersion
    )

    if (-not (Test-Path -LiteralPath $ModulePath)) {
        throw (New-PsModuleMigratorException -Message "Module path '$ModulePath' for '$ModuleName' version '$ModuleVersion' does not exist." -ErrorId 'ModuleSurfaceExportFailed' -Category 'InvalidOperation')
    }

    $tempScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("export-module-surface-{0}.ps1" -f ([guid]::NewGuid().ToString('N')))
    $scriptContent = @'
param(
    [Parameter(Mandatory)]
    [string]$ModulePath,

    [Parameter(Mandatory)]
    [string]$ModuleName
)

$ErrorActionPreference = 'Stop'
Import-Module -Name $ModulePath -Force -ErrorAction Stop | Out-Null
$commands = @(Get-Command -Module $ModuleName | Sort-Object Name, CommandType)
$aliases = @(Get-Alias | Where-Object Source -EQ $ModuleName | Sort-Object Name)
$result = [ordered]@{
    ModuleName = $ModuleName
    Commands   = @()
    Aliases    = @()
}

foreach ($command in $commands) {
    if ($command.CommandType -eq 'Alias') {
        continue
    }

    $commandAliases = @($aliases | Where-Object Definition -EQ $command.Name | Select-Object -ExpandProperty Name)
    $parameterSets = @()
    foreach ($parameterSet in $command.ParameterSets | Sort-Object Name) {
        $parameters = @()
        foreach ($parameter in $parameterSet.Parameters | Sort-Object Name -Unique) {
            $aliasAttribute = @($parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.AliasAttribute] } | ForEach-Object AliasNames)
            $parameters += [ordered]@{
                Name        = $parameter.Name
                IsMandatory = [bool]$parameter.IsMandatory
                Position    = if ($parameter.Position -ge 0) { [int]$parameter.Position } else { $null }
                TypeName    = if ($parameter.ParameterType) { $parameter.ParameterType.FullName } else { $null }
                Aliases     = @($aliasAttribute)
            }
        }

        $parameterSets += [ordered]@{
            Name       = $parameterSet.Name
            IsDefault  = ($command.DefaultParameterSet -eq $parameterSet.Name)
            Parameters = $parameters
        }
    }

    $result.Commands += [ordered]@{
        Name          = $command.Name
        CommandType   = [string]$command.CommandType
        ModuleName    = $ModuleName
        Aliases       = $commandAliases
        ParameterSets = $parameterSets
    }
}

foreach ($alias in $aliases) {
    $result.Aliases += [ordered]@{
        Name       = $alias.Name
        Definition = $alias.Definition
        ModuleName = $ModuleName
    }
}

$result | ConvertTo-Json -Depth 20
'@

    Set-Content -LiteralPath $tempScriptPath -Value $scriptContent -Encoding utf8

    try {
        $json = & pwsh -NoLogo -NoProfile -File $tempScriptPath -ModulePath $ModulePath -ModuleName $ModuleName 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw (New-PsModuleMigratorException -Message "Failed to export module surface for '$ModuleName' version '$ModuleVersion'. $($json -join ' ')" -ErrorId 'ModuleSurfaceExportFailed' -Category 'InvalidOperation')
        }

        return ($json -join [Environment]::NewLine) | ConvertFrom-Json -Depth 20
    }
    catch {
        if ($_.Exception.Data['ErrorId']) {
            throw
        }

        throw (New-PsModuleMigratorException -Message "Failed to export module surface for '$ModuleName' version '$ModuleVersion'. $($_.Exception.Message)" -ErrorId 'ModuleSurfaceExportFailed' -Category 'InvalidOperation')
    }
    finally {
        Remove-Item -LiteralPath $tempScriptPath -Force -ErrorAction SilentlyContinue
    }
}
