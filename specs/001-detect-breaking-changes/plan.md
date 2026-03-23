# Implementation Plan: Module Upgrade Breaking-Change Analysis

**Branch**: `001-detect-breaking-changes` | **Date**: 2026-03-22 | **Spec**: `specs/001-detect-breaking-changes/spec.md`
**Input**: Feature specification from `specs/001-detect-breaking-changes/spec.md`

## Summary

Create a cross-platform PowerShell 7.4+ module named `PsModuleMigrator` with a primary public cmdlet, `Find-ModuleUpgradeImpact`, that analyzes a local file, folder, or git repository for usages that are incompatible with a target PowerShell module version. The feature will resolve the requested or default target version, derive a structural breaking-change catalog by comparing the target module surface to the nearest lower analyzable version, scan PowerShell source files through AST-driven static analysis, and return actionable findings with file, line, usage, and remediation context while maintaining a TDD-first workflow and at least 90% automated coverage.

## Technical Context

**Language/Version**: PowerShell 7.4+  
**Primary Dependencies**: `System.Management.Automation` AST APIs, `Microsoft.PowerShell.PSResourceGet` for version resolution and module acquisition, Git CLI for repository enumeration, Pester 5.6+ for testing  
**Storage**: N/A; read-only analysis with temporary module download/cache directories only  
**Testing**: Pester 5.6+ unit, contract, and integration tests with coverage enforcement over public and private module functions  
**Target Platform**: PowerShell 7.4+ on Windows, macOS, and Linux; Git required when the analysis target is a repository  
**Project Type**: PowerShell module with CLI-style public cmdlets  
**Performance Goals**: Single-file analysis completes in <=5 seconds; folder or repository analysis of ~500 PowerShell files / 50k LOC completes in <=60 seconds on a developer workstation  
**Constraints**: Read-only target inspection, no unresolved module imports in the caller session, static structural compatibility checks only for MVP, deterministic offline re-runs after target module versions are cached, repository and feature coverage must remain >=90%  
**Scale/Scope**: One dependency module and one analysis target per run; supports a local file, local folder, or local git repository containing up to ~10k tracked files and ~1k PowerShell files  
**Coverage Target**: MUST remain at or above 90% automated code coverage

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Work is planned on a named feature branch; no implementation work will be performed directly on the default branch.
- [x] Each behavior change has failing automated tests identified before implementation begins.
- [x] The plan includes how automated coverage will be maintained or increased to at least 90%.
- [x] The spec defines independently testable user scenarios, acceptance criteria, and measurable outcomes.
- [x] Validation commands, including coverage reporting, are recorded for reviewer reproduction.

**Pre-Design Gate Outcome**: PASS. The feature branch is named correctly, the spec already defines independently testable stories and measurable outcomes, and the implementation strategy below preserves a Pester-first workflow with explicit coverage validation commands.

**Reviewer Validation Commands**

```bash
git -C . --no-pager branch --show-current
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/unit' -Output Detailed"
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/contract' -Output Detailed"
pwsh -NoLogo -NoProfile -Command "$config = New-PesterConfiguration; $config.Run.Path = 'tests'; $config.CodeCoverage.Enabled = $true; $config.CodeCoverage.Path = @('src/PsModuleMigrator/Public/*.ps1','src/PsModuleMigrator/Private/*.ps1'); Invoke-Pester -Configuration $config"
```

## Project Structure

### Documentation (this feature)

```text
specs/001-detect-breaking-changes/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── find-module-upgrade-impact.md
└── tasks.md
```

### Source Code (repository root)

```text

├── src/
│   └── PsModuleMigrator/
│       ├── PsModuleMigrator.psd1
│       ├── PsModuleMigrator.psm1
│       ├── Public/
│       │   └── Find-ModuleUpgradeImpact.ps1
│       ├── Private/
│       │   ├── Resolve-ModuleVersionContext.ps1
│       │   ├── Export-ModuleSurface.ps1
│       │   ├── Compare-ModuleSurface.ps1
│       │   ├── Get-AnalysisTargetFiles.ps1
│       │   ├── Find-CodebaseModuleUsage.ps1
│       │   └── New-UpgradeImpactReport.ps1
│       └── Data/
│           └── CompatibilityRules/
└── tests/
    ├── unit/
    ├── contract/
    ├── integration/
    └── fixtures/
        ├── modules/
        ├── projects/
        └── repositories/
```

**Structure Decision**: Use a single PowerShell module project rooted at `src/PsModuleMigrator` with clear `Public` and `Private` function boundaries, plus `unit`, `contract`, and `integration` Pester suites under `tests`. This structure matches the repository's greenfield state, makes red-green-refactor slices small and reviewable, and supports direct coverage enforcement on the feature's exported and internal commands.

## Phase 0 Research Summary

Phase 0 resolved all technical unknowns in `specs/001-detect-breaking-changes/research.md`:

- Build the feature as a PowerShell-native module instead of introducing another runtime.
- Resolve module versions with `Microsoft.PowerShell.PSResourceGet` and isolate module-surface inspection from the caller session.
- Detect structural breaking changes by comparing the target version to the nearest lower analyzable version and then matching those changes against AST-discovered code usage.
- Limit MVP findings to deterministic structural risks: removed commands, removed aliases, removed parameters, changed mandatory parameters, and missing exported commands referenced by the analyzed codebase.

## Phase 1 Design Summary

Phase 1 artifacts are produced in:

- `specs/001-detect-breaking-changes/data-model.md`
- `specs/001-detect-breaking-changes/contracts/find-module-upgrade-impact.md`
- `specs/001-detect-breaking-changes/quickstart.md`

The design formalizes the analysis request lifecycle, the report contract returned by `Find-ModuleUpgradeImpact`, and the validation workflow reviewers will use to reproduce TDD and coverage compliance.

## Post-Design Constitution Check

- [x] Work remains scoped to the named feature branch `001-detect-breaking-changes`.
- [x] Every user story maps to failing-first Pester test suites before production implementation starts.
- [x] The design preserves >=90% automated coverage by keeping public/private functions small and independently testable and by requiring coverage validation in the quickstart workflow.
- [x] The spec, contract, and data model define independently testable scenarios, outputs, and measurable outcomes.
- [x] Reviewer commands for branch verification, unit/contract execution, and coverage reporting are documented in this plan and the quickstart.

**Post-Design Gate Outcome**: PASS. No constitution exceptions are required. The design remains on a named feature branch, preserves test-first delivery, records reviewer commands, and constrains scope to a statically analyzable MVP that can be validated to the repository's 90% coverage floor.

## Complexity Tracking

No constitution violations or justified exceptions were identified during planning.
