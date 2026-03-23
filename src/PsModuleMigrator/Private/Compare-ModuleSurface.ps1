<#
.SYNOPSIS
Provides the `Compare-ModuleSurface` private helper implementation.

.DESCRIPTION
Contains repository PowerShell logic for `src/PsModuleMigrator/Private/Compare-ModuleSurface.ps1`.
#>


<#

.SYNOPSIS

Compares Module surface.


.DESCRIPTION

Provides comment-based help for `Compare-ModuleSurface`.


.PARAMETER BaselineSurface

Specifies the `BaselineSurface` value.


.PARAMETER TargetSurface

Specifies the `TargetSurface` value.


.PARAMETER BaselineVersion

Specifies the `BaselineVersion` value.


.PARAMETER TargetVersion

Specifies the `TargetVersion` value.

#>


function Compare-ModuleSurface {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$BaselineSurface,

        [Parameter(Mandatory)]
        [psobject]$TargetSurface,

        [Parameter(Mandatory)]
        [string]$BaselineVersion,

        [Parameter(Mandatory)]
        [string]$TargetVersion
    )
    <#

    .SYNOPSIS

    Gets Parameter map.

    

    .DESCRIPTION

    Provides comment-based help for `Get-ParameterMap`.

    

    .PARAMETER Command

    Specifies the `Command` value.

    #>


    function Get-ParameterMap {
        param([psobject]$Command)

        $map = @{}
        foreach ($parameterSet in $Command.ParameterSets) {
            foreach ($parameter in $parameterSet.Parameters) {
                if (-not $map.ContainsKey($parameter.Name)) {
                    $map[$parameter.Name] = [PSCustomObject]@{
                        Name        = $parameter.Name
                        IsMandatory = [bool]$parameter.IsMandatory
                    }
                }
                elseif ($parameter.IsMandatory) {
                    $map[$parameter.Name].IsMandatory = $true
                }
            }
        }

        return $map
    }

    $targetCommands = @{}
    foreach ($command in $TargetSurface.Commands) {
        $targetCommands[$command.Name] = $command
    }

    $targetAliases = @{}
    foreach ($alias in $TargetSurface.Aliases) {
        $targetAliases[$alias.Name] = $alias.Definition
    }

    $descriptors = [System.Collections.Generic.List[object]]::new()

    foreach ($baselineCommand in $BaselineSurface.Commands) {
        if (-not $targetCommands.ContainsKey($baselineCommand.Name)) {
            $descriptors.Add([PSCustomObject]@{
                    ChangeId             = "RemovedCommand:$($baselineCommand.Name)"
                    ChangeType           = 'RemovedCommand'
                    CommandName          = $baselineCommand.Name
                    ParameterName        = $null
                    Severity             = 'Critical'
                    BaselineVersion      = $BaselineVersion
                    TargetVersion        = $TargetVersion
                    Explanation          = "Command '$($baselineCommand.Name)' is exported by $($BaselineSurface.ModuleName) $BaselineVersion but not by $TargetVersion."
                    SuggestedRemediation = "Replace or remove usages of '$($baselineCommand.Name)' before upgrading to $TargetVersion."
                })
            continue
        }

        $baselineParameters = Get-ParameterMap -Command $baselineCommand
        $targetParameters = Get-ParameterMap -Command $targetCommands[$baselineCommand.Name]

        foreach ($parameterName in $baselineParameters.Keys) {
            if (-not $targetParameters.ContainsKey($parameterName)) {
                $descriptors.Add([PSCustomObject]@{
                        ChangeId             = "RemovedParameter:$($baselineCommand.Name):$parameterName"
                        ChangeType           = 'RemovedParameter'
                        CommandName          = $baselineCommand.Name
                        ParameterName        = $parameterName
                        Severity             = 'High'
                        BaselineVersion      = $BaselineVersion
                        TargetVersion        = $TargetVersion
                        Explanation          = "Parameter '-$parameterName' was removed from command '$($baselineCommand.Name)' in $TargetVersion."
                        SuggestedRemediation = "Update calls to '$($baselineCommand.Name)' to stop using '-$parameterName'."
                    })
            }
        }

        foreach ($parameterName in $targetParameters.Keys) {
            if ($targetParameters[$parameterName].IsMandatory -and ((-not $baselineParameters.ContainsKey($parameterName)) -or (-not $baselineParameters[$parameterName].IsMandatory))) {
                $descriptors.Add([PSCustomObject]@{
                        ChangeId             = "MandatoryParameterAdded:$($baselineCommand.Name):$parameterName"
                        ChangeType           = 'MandatoryParameterAdded'
                        CommandName          = $baselineCommand.Name
                        ParameterName        = $parameterName
                        Severity             = 'High'
                        BaselineVersion      = $BaselineVersion
                        TargetVersion        = $TargetVersion
                        Explanation          = "Parameter '-$parameterName' is mandatory in $TargetVersion for command '$($baselineCommand.Name)'."
                        SuggestedRemediation = "Pass '-$parameterName' whenever invoking '$($baselineCommand.Name)' after upgrading."
                    })
            }
        }
    }

    foreach ($baselineAlias in $BaselineSurface.Aliases) {
        if (-not $targetAliases.ContainsKey($baselineAlias.Name)) {
            $descriptors.Add([PSCustomObject]@{
                    ChangeId             = "RemovedAlias:$($baselineAlias.Name)"
                    ChangeType           = 'RemovedAlias'
                    CommandName          = $baselineAlias.Name
                    ParameterName        = $null
                    Severity             = 'Medium'
                    BaselineVersion      = $BaselineVersion
                    TargetVersion        = $TargetVersion
                    Explanation          = "Alias '$($baselineAlias.Name)' no longer resolves to '$($baselineAlias.Definition)' in $TargetVersion."
                    SuggestedRemediation = "Call '$($baselineAlias.Definition)' directly instead of '$($baselineAlias.Name)'."
                })
        }
    }

    return @($descriptors)
}
