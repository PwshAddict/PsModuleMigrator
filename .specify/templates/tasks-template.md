---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are REQUIRED. Every user story MUST begin with failing automated tests and end with passing validation plus coverage evidence.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create and publish the named feature branch for this work
- [ ] T002 Create project structure per implementation plan
- [ ] T003 [P] Configure linting, formatting, and test tooling
- [ ] T004 [P] Configure or verify coverage reporting that enforces the 90% minimum

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story implementation can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T005 Setup database schema and migrations framework
- [ ] T006 [P] Implement authentication/authorization framework
- [ ] T007 [P] Setup API routing and middleware structure
- [ ] T008 Create base models/entities that all stories depend on
- [ ] T009 Configure error handling and logging infrastructure
- [ ] T010 Setup environment configuration management

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 ⚠️

> **MANDATORY: Write these tests FIRST, ensure they FAIL for the expected reason, then implement the story.**

- [ ] T011 [P] [US1] Add or update unit test coverage in tests/unit/test_[name].py
- [ ] T012 [P] [US1] Add or update contract/regression test in tests/contract/test_[name].py
- [ ] T013 [P] [US1] Add or update integration test in tests/integration/test_[name].py
- [ ] T014 [US1] Run the new tests to capture failing-first evidence

### Implementation for User Story 1

- [ ] T015 [P] [US1] Create [Entity1] model in src/models/[entity1].py
- [ ] T016 [P] [US1] Create [Entity2] model in src/models/[entity2].py
- [ ] T017 [US1] Implement [Service] in src/services/[service].py (depends on T015, T016)
- [ ] T018 [US1] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T019 [US1] Add validation and error handling
- [ ] T020 [US1] Refactor with tests passing and update any required documentation
- [ ] T021 [US1] Run full validation and coverage commands; confirm repository coverage remains >= 90%

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 ⚠️

- [ ] T022 [P] [US2] Add or update unit test coverage in tests/unit/test_[name].py
- [ ] T023 [P] [US2] Add or update contract/regression test in tests/contract/test_[name].py
- [ ] T024 [P] [US2] Add or update integration test in tests/integration/test_[name].py
- [ ] T025 [US2] Run the new tests to capture failing-first evidence

### Implementation for User Story 2

- [ ] T026 [P] [US2] Create [Entity] model in src/models/[entity].py
- [ ] T027 [US2] Implement [Service] in src/services/[service].py
- [ ] T028 [US2] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T029 [US2] Integrate with User Story 1 components (if needed)
- [ ] T030 [US2] Refactor with tests passing and update any required documentation
- [ ] T031 [US2] Run full validation and coverage commands; confirm repository coverage remains >= 90%

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 ⚠️

- [ ] T032 [P] [US3] Add or update unit test coverage in tests/unit/test_[name].py
- [ ] T033 [P] [US3] Add or update contract/regression test in tests/contract/test_[name].py
- [ ] T034 [P] [US3] Add or update integration test in tests/integration/test_[name].py
- [ ] T035 [US3] Run the new tests to capture failing-first evidence

### Implementation for User Story 3

- [ ] T036 [P] [US3] Create [Entity] model in src/models/[entity].py
- [ ] T037 [US3] Implement [Service] in src/services/[service].py
- [ ] T038 [US3] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T039 [US3] Refactor with tests passing and update any required documentation
- [ ] T040 [US3] Run full validation and coverage commands; confirm repository coverage remains >= 90%

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Expand automated test coverage for shared paths if coverage is near threshold
- [ ] TXXX Security hardening
- [ ] TXXX Re-run full validation and coverage report before review

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests MUST be written first and MUST fail before implementation
- Coverage validation MUST run before the story is considered complete
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members on separate feature branches or branch-specific worktrees

---

## Parallel Example: User Story 1

```bash
# Launch all test authoring tasks for User Story 1 together:
Task: "Add unit test coverage in tests/unit/test_[name].py"
Task: "Add contract/regression test in tests/contract/test_[name].py"
Task: "Add integration test in tests/integration/test_[name].py"

# After tests fail, launch model work for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3 tests and capture failing-first evidence
4. Implement User Story 1
5. **STOP and VALIDATE**: Run full tests and coverage; confirm User Story 1 independently
6. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 tests first → Implement → Validate coverage → Deploy/Demo (MVP!)
3. Add User Story 2 tests first → Implement → Validate coverage → Deploy/Demo
4. Add User Story 3 tests first → Implement → Validate coverage → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 on its feature branch
   - Developer B: User Story 2 on its feature branch
   - Developer C: User Story 3 on its feature branch
3. Stories complete and integrate independently with coverage evidence per branch

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Validate coverage stays at or above 90% before requesting review
- Commit after each task or logical group on the feature branch
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
