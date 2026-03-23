# Research: Module Upgrade Breaking-Change Analysis

## Decision 1: Implement the feature as a PowerShell 7.4+ module

- **Decision**: Build the feature in PowerShell 7.4+ as a reusable module named `PsModuleMigrator` with a public cmdlet `Find-ModuleUpgradeImpact`.
- **Rationale**: The feature analyzes PowerShell source, so a PowerShell-native implementation can use `System.Management.Automation` AST APIs directly, ship as a standard module, and keep the developer and user workflow inside the same runtime. This also aligns naturally with the constitution's TDD and coverage requirements because Pester is the dominant testing tool for PowerShell modules.
- **Alternatives considered**: C#/.NET would offer strong typing but would add a build/runtime split for a PowerShell-focused audience; Python or Go would require cross-language parsing and packaging complexity with no feature benefit for the MVP.

## Decision 2: Use PSResourceGet to resolve the requested or default target module version

- **Decision**: Use `Microsoft.PowerShell.PSResourceGet` to discover the latest analyzable version when `-TargetVersion` is omitted and to download the explicit target version into a temporary cache when the user supplies one.
- **Rationale**: `PSResourceGet` is the modern PowerShell-native path for querying and saving module versions without forcing installation into the caller's environment. This enables deterministic analysis, clear invalid-version errors, and repeatable integration tests that can be driven from fixtures or cached test resources.
- **Alternatives considered**: `PowerShellGet` is older and less aligned with current PowerShell guidance; requiring the module to already be installed would make the feature unreliable and would weaken error-handling coverage for version resolution.

## Decision 3: Derive the breaking-change catalog dynamically from module-surface comparison

- **Decision**: Compare the target version's exported commands, aliases, parameter sets, and parameter metadata to the nearest lower analyzable version to build a structural breaking-change catalog for the run.
- **Rationale**: The user expects the tool to work for arbitrary PowerShell modules, not only for a curated registry. A dynamic comparison gives the MVP broad applicability while still keeping the problem tractable: structural differences in exported command surfaces are statically detectable and map directly to actionable findings in source code.
- **Alternatives considered**: A repository-owned JSON catalog would be deterministic but too narrow for a general-purpose module-upgrade workflow; attempting to detect behavioral changes dynamically would introduce low-confidence heuristics and weaken reproducibility.

## Decision 4: Inspect module surfaces in an isolated PowerShell session

- **Decision**: Export the module surface from a dedicated child `pwsh` process or isolated runspace rather than importing the target module into the user's current session.
- **Rationale**: The feature is explicitly read-only and should not mutate the caller's environment. Isolated inspection reduces side effects, avoids command collisions during analysis, and makes it easier to serialize command metadata for repeatable tests and fixture-driven comparisons.
- **Alternatives considered**: Importing directly into the active session would be simpler to code but could pollute the user session, break repeatability, and complicate test cleanup.

## Decision 5: Use AST-first static analysis with constrained regex fallback

- **Decision**: Parse `.ps1`, `.psm1`, and `.psd1` files with `[System.Management.Automation.Language.Parser]::ParseFile()` to discover command invocations, module-qualified calls, import statements, and parameter usage; use regex only for edge cases where AST parameter metadata is insufficient.
- **Rationale**: AST parsing provides deterministic file, line, and extent data without executing target code. That makes findings precise enough for user review and supports acceptance tests for both positive and no-findings scenarios.
- **Alternatives considered**: Regex-only scanning would be fragile and noisy; runtime execution of target code would violate the read-only constraint and produce non-deterministic results.

## Decision 6: Support local git repositories by enumerating tracked PowerShell files through Git

- **Decision**: For repository targets, prefer `git -C <repo> ls-files` to discover tracked `.ps1`, `.psm1`, and `.psd1` files, with a filesystem fallback only when git metadata cannot be read.
- **Rationale**: Enumerating tracked files respects `.gitignore`, avoids scanning transient build output, and matches the user story that the feature should analyze a repository without manual file enumeration. The fallback keeps the feature resilient when users point at a folder that is expected to be a repository but lacks a healthy index.
- **Alternatives considered**: Always walking the filesystem is simpler but noisier and less aligned with repository intent; cloning remote repositories is out of scope for the MVP because the spec only requires a path to a git repository.

## Decision 7: Keep the MVP scope limited to structural compatibility risks

- **Decision**: Report only deterministic, statically explainable risks in the MVP: removed commands, removed aliases, removed parameters, newly mandatory parameters, and module usages that cannot be satisfied by the target version's exported surface.
- **Rationale**: These categories are observable from module metadata and source code alone, which keeps findings reproducible and testable to the constitution's 90% coverage floor. Behavioral changes, type-shape changes, and runtime-only breakages are valuable future work but do not fit the spec's requirement for immediate, reviewable planning artifacts.
- **Alternatives considered**: Broader semantic or runtime analysis would promise more coverage of breakage types, but it would depend on executing arbitrary target code and would make the MVP harder to explain, test, and trust.

## Decision 8: Enforce TDD and coverage through Pester unit, contract, and integration suites

- **Decision**: Organize tests into `unit`, `contract`, and `integration` suites and require coverage enforcement against both exported and private functions through Pester 5.6+ configuration.
- **Rationale**: This directly satisfies the constitution and the feature spec's testability clauses. Unit tests cover diffing and AST scanning behavior, contract tests pin the public cmdlet interface and output shape, and integration tests exercise file/folder/repository flows with fixtures.
- **Alternatives considered**: Ad hoc manual testing would violate the constitution; unit-only testing would leave the public command contract and repository workflows under-specified.
