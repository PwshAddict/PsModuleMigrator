<#
.SYNOPSIS
Compares two exported module surfaces and returns breaking-change descriptors.

.DESCRIPTION
Compares commands, parameters, and aliases between a baseline module surface and
a target module surface. Returns a list of change descriptors for removals and
new mandatory parameters that may break existing scripts.

.PARAMETER BaselineSurface
The exported surface object for the baseline module version.

.PARAMETER TargetSurface
The exported surface object for the target module version.

.PARAMETER BaselineVersion
The baseline module version label used in descriptor metadata.

.PARAMETER TargetVersion
The target module version label used in descriptor metadata.

.OUTPUTS
System.Object[]
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
    Builds a lookup map for command parameters.

    .DESCRIPTION
    Flattens all parameter sets on a command into a hashtable keyed by parameter
    name and tracks whether each parameter is mandatory in any set.

    .PARAMETER Command
    The command metadata object that contains parameter set information.
    #>

}
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
