<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Modified principles:
  - Template Principle 1 -> I. Feature Branch Delivery
  - Template Principle 2 -> II. Test-Driven Development (NON-NEGOTIABLE)
  - Template Principle 3 -> III. Coverage Floor Enforcement
  - Template Principle 4 -> IV. Specification-Linked Testability
  - Template Principle 5 -> V. Small, Reviewable Change Sets
- Added sections:
  - Quality Standards
  - Development Workflow
- Removed sections:
  - None
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
  - ✅ .specify/templates/constitution-template.md
- Follow-up TODOs:
  - TODO(RATIFICATION_DATE): Original adoption date is unknown from repository context; replace when confirmed.
-->
# PsModuleMigrator Constitution

## Core Principles

### I. Feature Branch Delivery
All new work MUST start from and remain on a named feature branch before it is
merged. Direct commits to the default branch for feature, fix, refactor, or test
work are prohibited. Every change set MUST be traceable to a branch name, linked
specification, and review context so planning, validation, and rollback remain
auditable.

Rationale: Isolating work in feature branches preserves mainline stability and
creates a reviewable history for every change.

### II. Test-Driven Development (NON-NEGOTIABLE)
Behavior changes MUST follow a red-green-refactor workflow. Authors MUST write or
update automated tests before implementation, MUST confirm the new tests fail for
the intended reason, and MUST only then add or change production code. Bug fixes
MUST begin with a regression test that reproduces the defect. Work that cannot
be demonstrated through automated tests MUST document why and define the nearest
automated verification boundary.

Rationale: Test-first delivery reduces regressions and proves the intended
behavior before implementation details are optimized.

### III. Coverage Floor Enforcement
The repository MUST maintain at least 90% automated code coverage for the code
affected by a change, and the project-level coverage target MUST not fall below
90% on the default branch. Any pull request that reduces coverage below this
threshold MUST be blocked until coverage is restored or expanded. Coverage
reports MUST be produced by the repository's standard test tooling and reviewed
as part of change approval.

Rationale: A measurable coverage floor makes the TDD policy enforceable and
prevents untested paths from accumulating over time.

### IV. Specification-Linked Testability
Each feature specification MUST define independently testable user scenarios,
acceptance criteria, and observable success measures before implementation
planning begins. Plans and tasks MUST map implementation steps back to those
scenarios, with explicit test artifacts and validation commands recorded for each
story or change slice.

Rationale: Specifications that are testable by design enable reliable planning,
review, and release decisions.

### V. Small, Reviewable Change Sets
Changes MUST be delivered in the smallest reviewable increments that preserve
working behavior. Each branch MUST keep scope aligned to a single feature or
fix, MUST include any necessary documentation or test updates, and SHOULD avoid
bundling unrelated refactors unless the refactor is required to complete the
change safely. Exceptions MUST be justified in the plan and reviewed explicitly.

Rationale: Smaller changes are easier to test, review, and revert without
damaging delivery speed.

## Quality Standards

- Automated test suites MUST run before review and before merge.
- Unit, integration, and regression tests MUST be added or updated at the
  narrowest level that proves the requirement and at any broader boundary needed
  to prevent regressions.
- Coverage validation MUST be included in the definition of done for every
  change.
- Tooling, scripts, and CI configuration SHOULD fail fast when branch, test, or
  coverage requirements are violated.
- Manual-only validation MAY supplement automated checks, but it MUST NOT
  replace required automated tests or coverage evidence.

## Development Workflow

1. Create or update a specification that defines independently testable user
   scenarios and measurable outcomes.
2. Create a named feature branch before changing production code.
3. Write failing automated tests for the targeted behavior, then implement the
   minimum code required to pass them.
4. Refactor only with tests passing, while preserving or increasing coverage to
   at least 90%.
5. Record verification commands and coverage results in the plan, tasks, or pull
   request so reviewers can reproduce compliance.
6. Merge only after review confirms branch isolation, TDD evidence, and coverage
   compliance.

## Governance

This constitution is the authoritative engineering policy for PsModuleMigrator
and supersedes conflicting local habits or undocumented practices.

Amendment Procedure:
- Amendments MUST be proposed in a pull request that describes the affected
  principle, the reason for change, and any required template or workflow
  updates.
- Amendments MUST update all impacted SpecKit templates before approval so new
  work inherits the revised policy immediately.
- Amendments MUST be reviewed and approved by repository maintainers before
  adoption.

Versioning Policy:
- MAJOR version increments MUST be used for backward-incompatible governance
  changes, including principle removals or redefinitions that invalidate prior
  workflows.
- MINOR version increments MUST be used for new principles, new mandatory
  sections, or materially expanded guidance.
- PATCH version increments MUST be used for clarifications, wording
  improvements, typo fixes, and non-semantic refinements.
- The first concrete adoption of this constitution establishes version 1.0.0.

Compliance Review Expectations:
- Every plan, task list, and pull request MUST include an explicit constitution
  check covering feature-branch use, test-first execution, and 90% coverage.
- Reviewers MUST reject work that lacks failing-test evidence, coverage evidence,
  or branch isolation unless this constitution explicitly allows an exception.
- Periodic repository audits SHOULD verify that templates, automation, and
  merged changes still align with this constitution.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): Original adoption date is unknown from repository context; replace when confirmed. | **Last Amended**: 2026-03-22
