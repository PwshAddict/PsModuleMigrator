# Tasks: Module Upgrade Breaking-Change Analysis

**Input**: Design documents from `specs/001-detect-breaking-changes/`  
**Prerequisites**: `specs/001-detect-breaking-changes/plan.md`, `specs/001-detect-breaking-changes/spec.md`, `specs/001-detect-breaking-changes/research.md`, `specs/001-detect-breaking-changes/data-model.md`, `specs/001-detect-breaking-changes/contracts/find-module-upgrade-impact.md`, `specs/001-detect-breaking-changes/quickstart.md`

**Tests**: Tests are REQUIRED. Every user story begins with failing-first automated Pester coverage, ends with story-specific validation, and must keep repository coverage at or above 90% through `tests/Invoke-Coverage.ps1`.

**Organization**: Tasks are grouped by phase and then by user story so each story can be implemented, validated, and demonstrated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the PowerShell module shell, reusable test harness, and coverage gate scaffolding before any story work starts.

- [X] T001 Create the module manifest scaffold in src/PsModuleMigrator/PsModuleMigrator.psd1
- [X] T002 Create the module loader scaffold in src/PsModuleMigrator/PsModuleMigrator.psm1
- [X] T003 [P] Create shared Pester helper functions in tests/TestHelpers.psm1
- [X] T004 [P] Create the repository coverage gate runner in tests/Invoke-Coverage.ps1
- [X] T005 [P] Create fixture placeholder files in tests/fixtures/modules/.gitkeep, tests/fixtures/projects/.gitkeep, and tests/fixtures/repositories/.gitkeep

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the shared module-version comparison and report-building infrastructure required by every analysis target.

**⚠️ CRITICAL**: Complete this phase before starting any user story work.

- [X] T006 Create versioned comparison fixtures in tests/fixtures/modules/Az.Storage/4.0.0/Az.Storage.psd1 and tests/fixtures/modules/Az.Storage/5.0.0/Az.Storage.psd1
- [X] T007 [P] Implement analysis request and module version context resolution in src/PsModuleMigrator/Private/Resolve-ModuleVersionContext.ps1
- [X] T008 [P] Implement isolated module surface export in src/PsModuleMigrator/Private/Export-ModuleSurface.ps1
- [X] T009 [P] Implement structural breaking-change comparison in src/PsModuleMigrator/Private/Compare-ModuleSurface.ps1
- [X] T010 [P] Implement AnalysisRequest, AnalysisResult, and BreakingChangeFinding builders in src/PsModuleMigrator/Private/New-UpgradeImpactReport.ps1
- [X] T011 Wire public/private function loading and exports in src/PsModuleMigrator/PsModuleMigrator.psm1 and src/PsModuleMigrator/PsModuleMigrator.psd1

**Checkpoint**: Module version resolution, surface export, diffing, and report shaping are available for story implementation.

---

## Phase 3: User Story 1 - Analyze a local codebase for upgrade risk (Priority: P1) 🎯 MVP

**Goal**: Analyze a single file or folder, detect risky module usages through AST scanning, and return actionable findings or a clear no-findings result.

**Independent Test**: Import `src/PsModuleMigrator/PsModuleMigrator.psd1`, run `Find-ModuleUpgradeImpact` against `tests/fixtures/projects/single-file/sample.ps1` and `tests/fixtures/projects/folder-sample`, and confirm findings or no-findings outcomes match the fixture expectations without relying on repository scanning.

### Tests for User Story 1 ⚠️

> **MANDATORY**: Write these tests first, prove they fail for the intended reason, then implement the story.

- [X] T012 [P] [US1] Add failing AST and local-target unit coverage in tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1
- [X] T013 [P] [US1] Add failing success and no-findings contract coverage in tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1
- [X] T014 [P] [US1] Add failing single-file and folder integration coverage in tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1
- [X] T015 [US1] Run failing-first local-path tests in tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1, tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1, and tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1

### Implementation for User Story 1

- [X] T016 [P] [US1] Seed local analysis fixtures in tests/fixtures/projects/single-file/sample.ps1 and tests/fixtures/projects/folder-sample/Invoke-Sample.ps1
- [X] T017 [US1] Implement file and folder target discovery in src/PsModuleMigrator/Private/Get-AnalysisTargetFiles.ps1
- [X] T018 [US1] Implement AST-first command and parameter usage matching for local targets in src/PsModuleMigrator/Private/Find-CodebaseModuleUsage.ps1
- [X] T019 [US1] Implement local-path orchestration and no-findings result handling in src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1
- [X] T020 [US1] Run local-path validation in tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1, tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1, tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1, and tests/Invoke-Coverage.ps1

**Checkpoint**: User Story 1 delivers the MVP for file and folder analysis with reproducible failing-first evidence and coverage validation.

---

## Phase 4: User Story 2 - Analyze a git repository for upgrade risk (Priority: P2)

**Goal**: Detect upgrade risk across tracked PowerShell files in a local git repository and report findings grouped by affected file or location.

**Independent Test**: Run `Find-ModuleUpgradeImpact` against `tests/fixtures/repositories/sample-repo` and confirm repository-target results enumerate tracked files, surface risky usages by file, and return a clean no-usage result for the repository fixture that contains no relevant module references.

### Tests for User Story 2 ⚠️

- [X] T021 [P] [US2] Add failing repository enumeration unit coverage in tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1
- [X] T022 [P] [US2] Add failing repository result contract coverage in tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1
- [X] T023 [P] [US2] Add failing repository findings and no-usage integration coverage in tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1
- [X] T024 [US2] Run failing-first repository tests in tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1, tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1, and tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1

### Implementation for User Story 2

- [X] T025 [P] [US2] Seed repository fixture scripts in tests/fixtures/repositories/sample-repo/src/Invoke-RepoSample.ps1 and tests/fixtures/repositories/sample-repo/src/NoUsage.ps1
- [X] T026 [US2] Extend repository target discovery and git ls-files fallback handling in src/PsModuleMigrator/Private/Get-AnalysisTargetFiles.ps1
- [X] T027 [US2] Extend repository-scale usage aggregation in src/PsModuleMigrator/Private/Find-CodebaseModuleUsage.ps1 and src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1
- [X] T028 [US2] Run repository validation in tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1, tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1, tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1, and tests/Invoke-Coverage.ps1

**Checkpoint**: User Story 2 independently validates repository-target analysis without requiring manual file enumeration.

---

## Phase 5: User Story 3 - Target a specific module version (Priority: P3)

**Goal**: Respect an explicit `-TargetVersion`, resolve the comparison baseline, and surface clear invalid-version errors while preserving deterministic reporting.

**Independent Test**: Run `Find-ModuleUpgradeImpact -ModuleName Az.Storage -Path tests/fixtures/projects/single-file/sample.ps1 -TargetVersion 5.0.0` and confirm the result echoes the requested version, then run the same command with an invalid version fixture and confirm `InvalidTargetVersion` is raised.

### Tests for User Story 3 ⚠️

- [X] T029 [P] [US3] Add failing explicit-version unit coverage in tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1
- [X] T030 [P] [US3] Add failing explicit-version contract coverage in tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1
- [X] T031 [P] [US3] Add failing explicit-version integration coverage in tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1
- [X] T032 [US3] Run failing-first explicit-version tests in tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1, tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1, and tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1

### Implementation for User Story 3

- [X] T033 [P] [US3] Seed explicit-version fixtures in tests/fixtures/modules/Az.Storage/4.1.0/Az.Storage.psd1 and tests/fixtures/modules/Az.Storage/invalid-version.txt
- [X] T034 [US3] Implement explicit target-version and baseline resolution in src/PsModuleMigrator/Private/Resolve-ModuleVersionContext.ps1
- [X] T035 [US3] Implement isolated explicit-version surface export and InvalidTargetVersion failures in src/PsModuleMigrator/Private/Export-ModuleSurface.ps1
- [X] T036 [US3] Update version labels and error propagation in src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1 and src/PsModuleMigrator/Private/New-UpgradeImpactReport.ps1
- [X] T037 [US3] Run explicit-version validation in tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1, tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1, tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1, and tests/Invoke-Coverage.ps1

**Checkpoint**: User Story 3 independently validates explicit-version targeting and invalid-version error handling.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finish cross-story quality work, documentation, and final regression coverage before review.

- [X] T038 [P] Add mixed-result regression coverage in tests/integration/Find-ModuleUpgradeImpact.MixedResults.Tests.ps1
- [X] T039 [P] Add comment-based help and examples in src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1
- [X] T040 [P] Document module usage and reviewer validation commands in README.md
- [X] T041 Run full validation for tests/unit, tests/contract, tests/integration, and tests/Invoke-Coverage.ps1

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 and blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2; establishes the first end-to-end cmdlet slice and is the MVP.
- **User Story 2 (Phase 4)**: Depends on Phase 2 and reuses the file-discovery and AST-scanning pipeline stabilized in Phase 3.
- **User Story 3 (Phase 5)**: Depends on Phase 2 and layers explicit-version behavior onto the shared version-resolution pipeline used by the public cmdlet.
- **Polish (Phase 6)**: Depends on all selected user stories being complete.

### User Story Dependencies

- **US1**: No dependency on other stories after Foundational; complete this first for the MVP.
- **US2**: Functionally testable on its own, but implementation touches `src/PsModuleMigrator/Private/Get-AnalysisTargetFiles.ps1`, `src/PsModuleMigrator/Private/Find-CodebaseModuleUsage.ps1`, and `src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1`, so sequence it after US1 unless separate worktrees are used.
- **US3**: Functionally testable on its own, but implementation touches `src/PsModuleMigrator/Private/Resolve-ModuleVersionContext.ps1`, `src/PsModuleMigrator/Private/Export-ModuleSurface.ps1`, and `src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1`, so sequence it after the shared cmdlet path is stable.

### Within Each User Story

- Write tests first and verify they fail before changing production code.
- Create or update fixtures before final implementation passes.
- Update private functions before the public cmdlet when both are required.
- Run story-specific validation and `tests/Invoke-Coverage.ps1` before marking the story complete.

### Dependency Graph

```text
Phase 1 Setup
  -> Phase 2 Foundational
      -> Phase 3 US1 (MVP)
          -> Phase 4 US2
          -> Phase 5 US3
              -> Phase 6 Polish
```

---

## Parallel Opportunities

- **Setup**: `T003`, `T004`, and `T005` can run in parallel after `T001` and `T002` establish the module root files.
- **Foundational**: `T007`, `T008`, `T009`, and `T010` can run in parallel once `T006` seeds the shared comparison fixtures.
- **US1**: `T012`, `T013`, and `T014` can run in parallel; `T016` can proceed in parallel with those tests because it only seeds fixture files.
- **US2**: `T021`, `T022`, and `T023` can run in parallel; `T025` can run in parallel with those tests because it only changes repository fixtures.
- **US3**: `T029`, `T030`, and `T031` can run in parallel; `T033` can run in parallel with those tests because it only changes version fixtures.
- **Polish**: `T038`, `T039`, and `T040` can run in parallel before `T041` performs the final full-suite validation.

## Parallel Example: User Story 1

```bash
# Author the failing tests in parallel
Task: T012 tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1
Task: T013 tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1
Task: T014 tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1

# Seed fixtures while tests are being authored
Task: T016 tests/fixtures/projects/single-file/sample.ps1
```

## Parallel Example: User Story 2

```bash
# Author repository-focused tests in parallel
Task: T021 tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1
Task: T022 tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1
Task: T023 tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1

# Seed repository fixtures in parallel
Task: T025 tests/fixtures/repositories/sample-repo/src/Invoke-RepoSample.ps1
```

## Parallel Example: User Story 3

```bash
# Author version-targeting tests in parallel
Task: T029 tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1
Task: T030 tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1
Task: T031 tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1

# Seed explicit-version fixtures in parallel
Task: T033 tests/fixtures/modules/Az.Storage/4.1.0/Az.Storage.psd1
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 Setup to establish the module shell and reusable test harness.
2. Complete Phase 2 Foundational so version resolution, module-surface export, diffing, and report builders are ready.
3. Execute `T012`-`T015` to prove the MVP tests fail first.
4. Implement `T016`-`T019` to deliver file and folder analysis.
5. Execute `T020` and stop for review once US1 is green and coverage remains at or above 90%.

### Incremental Delivery

1. Deliver **US1** as the MVP for local file and folder analysis.
2. Add **US2** to expand the same analysis engine to git repository targets.
3. Add **US3** to support explicit version selection and invalid-version validation.
4. Finish with **Phase 6 Polish** for shared regression coverage, help text, and final docs.

### Multi-LLM / Multi-Developer Strategy

1. One contributor completes Phases 1-2.
2. After Phase 2, one contributor can own US1 while others prepare US2 and US3 test files and fixtures in separate worktrees.
3. Merge story branches in priority order because US2 and US3 both touch the public cmdlet and shared private helper scripts.

---

## Notes

- Every checklist item follows the required `- [X] T### [P?] [US#?] Description with exact file path` format.
- `[P]` tasks are limited to work on distinct files with no incomplete prerequisite dependency.
- Each user story includes explicit failing-first tests, independent validation criteria, and a coverage gate task.
- The planned source layout remains rooted at `src/PsModuleMigrator` and `tests`.
- Use the reviewer commands recorded in `specs/001-detect-breaking-changes/quickstart.md` when executing validation tasks.
