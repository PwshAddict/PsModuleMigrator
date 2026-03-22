# PsModuleMigrator Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-22

## Active Technologies
- PowerShell 7.4+ + `System.Management.Automation` AST APIs, `Microsoft.PowerShell.PSResourceGet` for version resolution and module acquisition, Git CLI for repository enumeration, Pester 5.6+ for testing (001-detect-breaking-changes)
- N/A; read-only analysis with temporary module download/cache directories only (001-detect-breaking-changes)

- PowerShell 7.4+
- `System.Management.Automation` AST APIs for static analysis
- `Microsoft.PowerShell.PSResourceGet` for module version resolution and acquisition
- Git CLI for repository file enumeration
- Pester 5.6+ for unit, contract, integration, and coverage validation

## Project Structure

```text
src/
└── PsModuleMigrator/
    ├── PsModuleMigrator.psd1
    ├── PsModuleMigrator.psm1
    ├── Public/
    │   └── Find-ModuleUpgradeImpact.ps1
    ├── Private/
    │   ├── Resolve-ModuleVersionContext.ps1
    │   ├── Export-ModuleSurface.ps1
    │   ├── Compare-ModuleSurface.ps1
    │   ├── Get-AnalysisTargetFiles.ps1
    │   ├── Find-CodebaseModuleUsage.ps1
    │   └── New-UpgradeImpactReport.ps1
    └── Data/
        └── CompatibilityRules/

tests/
├── unit/
├── contract/
├── integration/
└── fixtures/
```

## Commands

- `git -C . --no-pager branch --show-current`
- `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/unit' -Output Detailed"`
- `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/contract' -Output Detailed"`
- `pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path 'tests/integration' -Output Detailed"`
- `pwsh -NoLogo -NoProfile -Command "$config = New-PesterConfiguration; $config.Run.Path = 'tests'; $config.CodeCoverage.Enabled = $true; $config.CodeCoverage.Path = @('src/PsModuleMigrator/Public/*.ps1','src/PsModuleMigrator/Private/*.ps1'); $result = Invoke-Pester -Configuration $config; if ($result.CodeCoverage.CoveragePercent -lt 90) { throw 'Coverage below 90%' }"`

## Code Style

- Use approved PowerShell verb-noun command names.
- Keep exported cmdlets in `Public/` and helper functions in `Private/`.
- Prefer AST-driven static analysis over regex; use regex only as a constrained fallback.
- Return structured `PSCustomObject` results that include explicit status, version labels, and findings.
- Preserve TDD-first delivery: add failing Pester tests before production code changes.

## Recent Changes
- 001-detect-breaking-changes: Added PowerShell 7.4+ + `System.Management.Automation` AST APIs, `Microsoft.PowerShell.PSResourceGet` for version resolution and module acquisition, Git CLI for repository enumeration, Pester 5.6+ for testing

- `001-detect-breaking-changes`: Planned `Find-ModuleUpgradeImpact` for file, folder, and repository analysis against a target PowerShell module version using dynamic module-surface comparison and AST-based finding detection.

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
