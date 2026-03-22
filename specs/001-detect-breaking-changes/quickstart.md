# Quickstart: Module Upgrade Breaking-Change Analysis

## Goal

Plan and validate the `001-detect-breaking-changes` feature for `/Users/scott/code/github/pwshaddict/PsModuleMigrator` before implementation begins. The implementation will ship a PowerShell module `PsModuleMigrator` that exports `Find-ModuleUpgradeImpact`.

## Planned Source Layout

```text
/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/
├── PsModuleMigrator.psd1
├── PsModuleMigrator.psm1
├── Public/Find-ModuleUpgradeImpact.ps1
├── Private/
└── Data/CompatibilityRules/
```

## Planned Public Command

```powershell
Find-ModuleUpgradeImpact -ModuleName <string> -Path <string> [-TargetVersion <string>]
```

- `-ModuleName` is required.
- `-Path` accepts exactly one local file, local folder, or local git repository root.
- `-TargetVersion` is optional; if omitted, the feature resolves the latest analyzable version.

## Example Usage Scenarios

### 1. Analyze a single file

```powershell
Import-Module /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/PsModuleMigrator.psd1 -Force
Find-ModuleUpgradeImpact -ModuleName Az.Storage -Path /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/single-file/sample.ps1 -TargetVersion 5.0.0
```

### 2. Analyze a folder

```powershell
Find-ModuleUpgradeImpact -ModuleName Pester -Path /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/folder-sample
```

### 3. Analyze a local git repository

```powershell
Find-ModuleUpgradeImpact -ModuleName Microsoft.Graph.Authentication -Path /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/repositories/sample-repo -TargetVersion 2.0.0
```

## TDD Workflow

1. Add or update a failing Pester test in `/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit`, `/contract`, or `/integration` before creating production code.
2. Confirm the new test fails for the intended reason.
3. Implement the minimum code under `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator` to make the test pass.
4. Refactor with all tests green.
5. Re-run coverage and confirm the project remains at or above 90%.

## Reviewer Validation Commands

### Branch check

```bash
git -C /Users/scott/code/github/pwshaddict/PsModuleMigrator --no-pager branch --show-current
```

### Unit tests

```bash
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path '/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit' -Output Detailed"
```

### Contract tests

```bash
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path '/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract' -Output Detailed"
```

### Integration tests

```bash
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path '/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration' -Output Detailed"
```

### Coverage gate

```bash
pwsh -NoLogo -NoProfile -Command "$config = New-PesterConfiguration; $config.Run.Path = '/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests'; $config.CodeCoverage.Enabled = $true; $config.CodeCoverage.Path = @('/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Public/*.ps1','/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/*.ps1'); $result = Invoke-Pester -Configuration $config; if ($result.CodeCoverage.CoveragePercent -lt 90) { throw 'Coverage below 90%' }"
```

## Planned Test Mapping

- **User Story 1 / P1**: Unit + integration fixtures for single-file and folder analysis, risk finding detection, and no-findings outcomes.
- **User Story 2 / P2**: Integration fixtures for git repository enumeration, tracked-file scanning, and repository no-usage results.
- **User Story 3 / P3**: Unit + contract fixtures for explicit target-version resolution, invalid version failures, and result version labeling.

## Generated Planning Artifacts

- Plan: `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/plan.md`
- Research: `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/research.md`
- Data model: `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/data-model.md`
- Contract: `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/contracts/find-module-upgrade-impact.md`
- Quickstart: `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/quickstart.md`
