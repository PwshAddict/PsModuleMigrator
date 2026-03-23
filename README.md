# PsModuleMigrator

`PsModuleMigrator` is a PowerShell module for detecting likely breaking changes before upgrading a dependency module in a PowerShell codebase.

## Public Command

```powershell
Find-ModuleUpgradeImpact -ModuleName <string> -Path <string> [-TargetVersion <string>]
```

- `-ModuleName` is required.
- `-Path` accepts one local file, one local folder, or one local git repository.
- `-TargetVersion` is optional. If omitted, the command analyzes the latest analyzable version.

## Example Usage

```powershell
Import-Module src/PsModuleMigrator/PsModuleMigrator.psd1 -Force
Find-ModuleUpgradeImpact -ModuleName Az.Storage -Path tests/fixtures/projects/single-file/sample.ps1 -TargetVersion 5.0.0
```

## Validation Commands

```bash
git --no-pager branch --show-current
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/unit' -Output Detailed"
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/contract' -Output Detailed"
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/integration' -Output Detailed"
pwsh -NoLogo -NoProfile -File tests/Invoke-Coverage.ps1
```
