function Find-CodebaseModuleUsage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [string[]]$FilePaths,

        [Parameter(Mandatory)]
        [object[]]$BreakingChangeDescriptors,

        [Parameter(Mandatory)]
        [psobject]$TargetSurface,

        [Parameter(Mandatory)]
        [guid]$RequestId
    )

    function Get-NormalizedCommandName {
        param([Parameter(Mandatory)][string]$CommandName)

        $normalized = $CommandName
        if ($normalized.Contains('\')) {
            $normalized = $normalized.Split('\')[-1]
        }

        if ($normalized.Contains(':')) {
            $normalized = $normalized.Split(':')[-1]
        }

        return $normalized
    }

    $descriptorLookup = @{}
    foreach ($descriptor in $BreakingChangeDescriptors) {
        if (-not $descriptorLookup.ContainsKey($descriptor.CommandName)) {
            $descriptorLookup[$descriptor.CommandName] = [System.Collections.Generic.List[object]]::new()
        }

        $descriptorLookup[$descriptor.CommandName].Add($descriptor)
    }

    $targetCommandNames = @{}
    foreach ($command in $TargetSurface.Commands) {
        $targetCommandNames[$command.Name] = $true
    }

    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($filePath in $FilePaths | Sort-Object -Unique) {
        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            continue
        }

        try {
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$tokens, [ref]$parseErrors)
        }
        catch {
            throw (New-PsModuleMigratorException -Message "AST analysis failed for '$filePath'. $($_.Exception.Message)" -ErrorId 'AnalysisFailed' -Category 'InvalidOperation')
        }

        $commandAsts = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
        foreach ($commandAst in $commandAsts) {
            $rawCommandName = $commandAst.GetCommandName()
            if ([string]::IsNullOrWhiteSpace($rawCommandName)) {
                continue
            }

            $normalizedCommandName = Get-NormalizedCommandName -CommandName $rawCommandName
            $parameterNames = @($commandAst.CommandElements |
                Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] } |
                ForEach-Object { $_.ParameterName })
            $reference = [PSCustomObject]@{
                FilePath     = (Get-Item -LiteralPath $filePath).FullName
                LineNumber   = $commandAst.Extent.StartLineNumber
                ColumnNumber = $commandAst.Extent.StartColumnNumber
                SourceText   = $commandAst.Extent.Text.Trim()
            }

            if ($descriptorLookup.ContainsKey($normalizedCommandName)) {
                foreach ($descriptor in $descriptorLookup[$normalizedCommandName]) {
                    $shouldReport = switch ($descriptor.ChangeType) {
                        'RemovedCommand' { $true }
                        'RemovedAlias' { $true }
                        'RemovedParameter' { $parameterNames -contains $descriptor.ParameterName }
                        'MandatoryParameterAdded' { $parameterNames -notcontains $descriptor.ParameterName }
                        'CommandMissingFromTarget' { $true }
                        default { $false }
                    }

                    if ($shouldReport) {
                        $findings.Add((New-BreakingChangeFinding -RequestId $RequestId -Descriptor $descriptor -Reference $reference -Confidence 'High'))
                    }
                }

                continue
            }

            if (($rawCommandName -like "$ModuleName\*") -and (-not $targetCommandNames.ContainsKey($normalizedCommandName))) {
                $descriptor = [PSCustomObject]@{
                    ChangeType           = 'CommandMissingFromTarget'
                    Severity             = 'Critical'
                    CommandName          = $normalizedCommandName
                    ParameterName        = $null
                    Explanation          = "Command '$normalizedCommandName' is referenced as a $ModuleName command but is not exported by the target module version."
                    SuggestedRemediation = "Replace or remove usages of '$normalizedCommandName' before upgrading."
                }
                $findings.Add((New-BreakingChangeFinding -RequestId $RequestId -Descriptor $descriptor -Reference $reference -Confidence 'High'))
            }
        }
    }

    return @($findings.ToArray())
}
