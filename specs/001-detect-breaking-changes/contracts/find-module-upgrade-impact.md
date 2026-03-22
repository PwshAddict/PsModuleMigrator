# Contract: Find-ModuleUpgradeImpact

## Command Purpose

`Find-ModuleUpgradeImpact` analyzes one local file, one local folder, or one local git repository for usages that are incompatible with a target PowerShell module version.

## PowerShell Signature

```powershell
function Find-ModuleUpgradeImpact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$TargetVersion
    )
}
```

## Input Contract

| Parameter | Type | Required | Rules | Failure Contract |
|---|---|---:|---|---|
| `ModuleName` | `string` | Yes | Non-empty module name; must resolve through local metadata or PSResourceGet | `InvalidModuleName` / `ObjectNotFound` |
| `Path` | `string` | Yes | Absolute or relative path to one existing file, folder, or local git repository | `InvalidTargetPath` / `InvalidArgument` |
| `TargetVersion` | `string` | No | If supplied, must resolve to an analyzable version of `ModuleName` | `InvalidTargetVersion` / `InvalidArgument` |

## Target Resolution Rules

1. If `Path` is a file, the request is treated as `TargetKind = File`.
2. If `Path` is a directory containing `.git`, the request is treated as `TargetKind = Repository` and tracked PowerShell files are enumerated with `git ls-files`.
3. If `Path` is a directory without `.git`, the request is treated as `TargetKind = Folder` and PowerShell files are discovered recursively.
4. If `TargetVersion` is omitted, the cmdlet resolves the latest analyzable version and records it in the result as `ResolvedTargetVersion`.
5. The analyzer also resolves `BaselineVersion` as the nearest lower analyzable version used to derive structural changes.

## Output Contract

Successful execution returns one `PSCustomObject` with the following shape:

```powershell
[PSCustomObject]@{
    RequestId              = [guid]
    ModuleName             = [string]
    TargetKind             = 'File' | 'Folder' | 'Repository'
    TargetPath             = [string]
    ResolvedTargetVersion  = [string]
    BaselineVersion        = [string]
    Status                 = 'CompletedWithFindings' | 'CompletedWithoutFindings'
    FindingCount           = [int]
    AffectedFileCount      = [int]
    Findings               = @(
        [PSCustomObject]@{
            FindingId            = [string]
            ChangeType           = 'RemovedCommand' | 'RemovedAlias' | 'RemovedParameter' | 'MandatoryParameterAdded' | 'CommandMissingFromTarget'
            Severity             = 'Critical' | 'High' | 'Medium'
            CommandName          = [string]
            ParameterName        = [string]
            FilePath             = [string]
            LineNumber           = [int]
            ColumnNumber         = [int]
            SourceText           = [string]
            Confidence           = 'High' | 'Medium'
            Explanation          = [string]
            SuggestedRemediation = [string]
        }
    )
    Warnings               = @([string])
    DurationMs             = [int]
}
```

## No-Findings Contract

When no risky usage is detected, the cmdlet still returns a result object with:

- `Status = 'CompletedWithoutFindings'`
- `FindingCount = 0`
- `AffectedFileCount = 0`
- `Findings = @()`
- `ResolvedTargetVersion` populated so the user can see which version was evaluated

## Error Contract

Errors are surfaced through standard PowerShell error records with these stable identifiers:

| ErrorId | Category | Trigger | Expected Message Shape |
|---|---|---|---|
| `InvalidModuleName` | `ObjectNotFound` | Module cannot be resolved | Explains which module name failed |
| `InvalidTargetPath` | `InvalidArgument` | Path is missing or unreadable | Explains the invalid target path |
| `InvalidTargetVersion` | `InvalidArgument` | Target version is malformed or unavailable | Explains which version failed to resolve |
| `ModuleSurfaceExportFailed` | `InvalidOperation` | Isolated metadata inspection failed | Explains which module/version failed |
| `RepositoryEnumerationFailed` | `InvalidOperation` | `git ls-files` could not enumerate tracked files | Explains the repository path |
| `AnalysisFailed` | `InvalidOperation` | AST scan or matching failed unexpectedly | Includes a concise recovery hint |

## Contract Test Requirements

Each implementation slice must add failing-first Pester tests that prove this contract:

1. **Contract / success**: valid file input returns the documented object shape.
2. **Contract / repository**: git repository input produces `TargetKind = Repository` and groups findings by file.
3. **Contract / no findings**: compatible input returns `CompletedWithoutFindings` and an empty `Findings` array.
4. **Contract / explicit version**: a valid `-TargetVersion` is echoed as `ResolvedTargetVersion`.
5. **Contract / invalid version**: an invalid `-TargetVersion` produces `InvalidTargetVersion`.

## Example Invocation

```powershell
Import-Module /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/PsModuleMigrator.psd1 -Force
Find-ModuleUpgradeImpact -ModuleName Az.Storage -Path /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/repositories/sample-repo -TargetVersion 5.0.0
```
