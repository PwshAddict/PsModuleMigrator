# Tasks: Module Upgrade Breaking-Change Analysis

**Input**: Design documents from `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/`  
**Prerequisites**: `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/plan.md`, `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/spec.md`, `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/research.md`, `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/data-model.md`, `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/contracts/find-module-upgrade-impact.md`, `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/quickstart.md`

**Tests**: Tests are REQUIRED. Every user story begins with failing-first automated Pester coverage, ends with story-specific validation, and must keep repository coverage at or above 90% through `/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/Invoke-Coverage.ps1`.

**Organization**: Tasks are grouped by phase and then by user story so each story can be implemented, validated, and demonstrated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the PowerShell module shell, reusable test harness, and coverage gate scaffolding before any story work starts.

- [ ] T001 Create the module manifest scaffold in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/PsModuleMigrator.psd1
- [ ] T002 Create the module loader scaffold in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/PsModuleMigrator.psm1
- [ ] T003 [P] Create shared Pester helper functions in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/TestHelpers.psm1
- [ ] T004 [P] Create the repository coverage gate runner in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/Invoke-Coverage.ps1
- [ ] T005 [P] Create fixture placeholder files in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/modules/.gitkeep, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/.gitkeep, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/repositories/.gitkeep

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the shared module-version comparison and report-building infrastructure required by every analysis target.

**⚠️ CRITICAL**: Complete this phase before starting any user story work.

- [ ] T006 Create versioned comparison fixtures in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/modules/Az.Storage/4.0.0/Az.Storage.psd1 and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/modules/Az.Storage/5.0.0/Az.Storage.psd1
- [ ] T007 [P] Implement analysis request and module version context resolution in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Resolve-ModuleVersionContext.ps1
- [ ] T008 [P] Implement isolated module surface export in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Export-ModuleSurface.ps1
- [ ] T009 [P] Implement structural breaking-change comparison in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Compare-ModuleSurface.ps1
- [ ] T010 [P] Implement AnalysisRequest, AnalysisResult, and BreakingChangeFinding builders in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/New-UpgradeImpactReport.ps1
- [ ] T011 Wire public/private function loading and exports in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/PsModuleMigrator.psm1 and /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/PsModuleMigrator.psd1

**Checkpoint**: Module version resolution, surface export, diffing, and report shaping are available for story implementation.

---

## Phase 3: User Story 1 - Analyze a local codebase for upgrade risk (Priority: P1) 🎯 MVP

**Goal**: Analyze a single file or folder, detect risky module usages through AST scanning, and return actionable findings or a clear no-findings result.

**Independent Test**: Import `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/PsModuleMigrator.psd1`, run `Find-ModuleUpgradeImpact` against `/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/single-file/sample.ps1` and `/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/folder-sample`, and confirm findings or no-findings outcomes match the fixture expectations without relying on repository scanning.

### Tests for User Story 1 ⚠️

> **MANDATORY**: Write these tests first, prove they fail for the intended reason, then implement the story.

- [ ] T012 [P] [US1] Add failing AST and local-target unit coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1
- [ ] T013 [P] [US1] Add failing success and no-findings contract coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1
- [ ] T014 [P] [US1] Add failing single-file and folder integration coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1
- [ ] T015 [US1] Run failing-first local-path tests in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1

### Implementation for User Story 1

- [ ] T016 [P] [US1] Seed local analysis fixtures in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/single-file/sample.ps1 and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/folder-sample/Invoke-Sample.ps1
- [ ] T017 [US1] Implement file and folder target discovery in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Get-AnalysisTargetFiles.ps1
- [ ] T018 [US1] Implement AST-first command and parameter usage matching for local targets in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Find-CodebaseModuleUsage.ps1
- [ ] T019 [US1] Implement local-path orchestration and no-findings result handling in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1
- [ ] T020 [US1] Run local-path validation in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/Invoke-Coverage.ps1

**Checkpoint**: User Story 1 delivers the MVP for file and folder analysis with reproducible failing-first evidence and coverage validation.

---

## Phase 4: User Story 2 - Analyze a git repository for upgrade risk (Priority: P2)

**Goal**: Detect upgrade risk across tracked PowerShell files in a local git repository and report findings grouped by affected file or location.

**Independent Test**: Run `Find-ModuleUpgradeImpact` against `/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/repositories/sample-repo` and confirm repository-target results enumerate tracked files, surface risky usages by file, and return a clean no-usage result for the repository fixture that contains no relevant module references.

### Tests for User Story 2 ⚠️

- [ ] T021 [P] [US2] Add failing repository enumeration unit coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1
- [ ] T022 [P] [US2] Add failing repository result contract coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1
- [ ] T023 [P] [US2] Add failing repository findings and no-usage integration coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1
- [ ] T024 [US2] Run failing-first repository tests in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1

### Implementation for User Story 2

- [ ] T025 [P] [US2] Seed repository fixture scripts in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/repositories/sample-repo/src/Invoke-RepoSample.ps1 and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/repositories/sample-repo/src/NoUsage.ps1
- [ ] T026 [US2] Extend repository target discovery and git ls-files fallback handling in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Get-AnalysisTargetFiles.ps1
- [ ] T027 [US2] Extend repository-scale usage aggregation in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Find-CodebaseModuleUsage.ps1 and /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1
- [ ] T028 [US2] Run repository validation in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/Invoke-Coverage.ps1

**Checkpoint**: User Story 2 independently validates repository-target analysis without requiring manual file enumeration.

---

## Phase 5: User Story 3 - Target a specific module version (Priority: P3)

**Goal**: Respect an explicit `-TargetVersion`, resolve the comparison baseline, and surface clear invalid-version errors while preserving deterministic reporting.

**Independent Test**: Run `Find-ModuleUpgradeImpact -ModuleName Az.Storage -Path /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/single-file/sample.ps1 -TargetVersion 5.0.0` and confirm the result echoes the requested version, then run the same command with an invalid version fixture and confirm `InvalidTargetVersion` is raised.

### Tests for User Story 3 ⚠️

- [ ] T029 [P] [US3] Add failing explicit-version unit coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1
- [ ] T030 [P] [US3] Add failing explicit-version contract coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1
- [ ] T031 [P] [US3] Add failing explicit-version integration coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1
- [ ] T032 [US3] Run failing-first explicit-version tests in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1

### Implementation for User Story 3

- [ ] T033 [P] [US3] Seed explicit-version fixtures in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/modules/Az.Storage/4.1.0/Az.Storage.psd1 and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/modules/Az.Storage/invalid-version.txt
- [ ] T034 [US3] Implement explicit target-version and baseline resolution in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Resolve-ModuleVersionContext.ps1
- [ ] T035 [US3] Implement isolated explicit-version surface export and InvalidTargetVersion failures in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Export-ModuleSurface.ps1
- [ ] T036 [US3] Update version labels and error propagation in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1 and /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/New-UpgradeImpactReport.ps1
- [ ] T037 [US3] Run explicit-version validation in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/Invoke-Coverage.ps1

**Checkpoint**: User Story 3 independently validates explicit-version targeting and invalid-version error handling.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finish cross-story quality work, documentation, and final regression coverage before review.

- [ ] T038 [P] Add mixed-result regression coverage in /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.MixedResults.Tests.ps1
- [ ] T039 [P] Add comment-based help and examples in /Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1
- [ ] T040 [P] Document module usage and reviewer validation commands in /Users/scott/code/github/pwshaddict/PsModuleMigrator/README.md
- [ ] T041 Run full validation for /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract, /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration, and /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/Invoke-Coverage.ps1

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
- **US2**: Functionally testable on its own, but implementation touches `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Get-AnalysisTargetFiles.ps1`, `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Find-CodebaseModuleUsage.ps1`, and `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1`, so sequence it after US1 unless separate worktrees are used.
- **US3**: Functionally testable on its own, but implementation touches `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Resolve-ModuleVersionContext.ps1`, `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Private/Export-ModuleSurface.ps1`, and `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator/Public/Find-ModuleUpgradeImpact.ps1`, so sequence it after the shared cmdlet path is stable.

### Within Each User Story

- Write tests first and verify they fail before changing production code.
- Create or update fixtures before final implementation passes.
- Update private functions before the public cmdlet when both are required.
- Run story-specific validation and `/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/Invoke-Coverage.ps1` before marking the story complete.

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
Task: T012 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Find-CodebaseModuleUsage.Local.Tests.ps1
Task: T013 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Local.Contract.Tests.ps1
Task: T014 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.LocalTargets.Tests.ps1

# Seed fixtures while tests are being authored
Task: T016 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/projects/single-file/sample.ps1
```

## Parallel Example: User Story 2

```bash
# Author repository-focused tests in parallel
Task: T021 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Get-AnalysisTargetFiles.Repository.Tests.ps1
Task: T022 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Repository.Contract.Tests.ps1
Task: T023 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.Repository.Tests.ps1

# Seed repository fixtures in parallel
Task: T025 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/repositories/sample-repo/src/Invoke-RepoSample.ps1
```

## Parallel Example: User Story 3

```bash
# Author version-targeting tests in parallel
Task: T029 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/unit/Resolve-ModuleVersionContext.Version.Tests.ps1
Task: T030 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/contract/Find-ModuleUpgradeImpact.Version.Contract.Tests.ps1
Task: T031 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/integration/Find-ModuleUpgradeImpact.VersionSelection.Tests.ps1

# Seed explicit-version fixtures in parallel
Task: T033 /Users/scott/code/github/pwshaddict/PsModuleMigrator/tests/fixtures/modules/Az.Storage/4.1.0/Az.Storage.psd1
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

- Every checklist item follows the required `- [ ] T### [P?] [US#?] Description with exact file path` format.
- `[P]` tasks are limited to work on distinct files with no incomplete prerequisite dependency.
- Each user story includes explicit failing-first tests, independent validation criteria, and a coverage gate task.
- The planned source layout remains rooted at `/Users/scott/code/github/pwshaddict/PsModuleMigrator/src/PsModuleMigrator` and `/Users/scott/code/github/pwshaddict/PsModuleMigrator/tests`.
- Use the reviewer commands recorded in `/Users/scott/code/github/pwshaddict/PsModuleMigrator/specs/001-detect-breaking-changes/quickstart.md` when executing validation tasks.
