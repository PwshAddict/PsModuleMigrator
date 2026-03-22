# Data Model: Module Upgrade Breaking-Change Analysis

## 1. AnalysisRequest

| Field | Type | Required | Description | Validation |
|---|---|---:|---|---|
| `RequestId` | `guid` | Yes | Unique identifier for a single analysis run | Generated at request start |
| `ModuleName` | `string` | Yes | PowerShell module being evaluated for upgrade compatibility | Non-empty; valid module name token |
| `TargetPath` | `string` | Yes | Absolute path to the file, folder, or local git repository under analysis | Must exist and be readable |
| `TargetKind` | `enum(File, Folder, Repository)` | Yes | Resolved target type based on the supplied path | Exactly one kind per request |
| `TargetVersion` | `string` | No | Explicit module version requested by the user | Must resolve through PSResourceGet when supplied |
| `ResolvedTargetVersion` | `string` | Yes | Concrete version actually analyzed | Must be recorded in the final report |
| `BaselineVersion` | `string` | Yes | Nearest lower analyzable version used to derive structural differences | Must be less than `ResolvedTargetVersion` |
| `RequestedAtUtc` | `datetime` | Yes | Timestamp of request creation | Set automatically |

**Relationships**
- `AnalysisRequest` has one `ModuleVersionContext`.
- `AnalysisRequest` produces one `AnalysisResult`.
- `AnalysisRequest` can generate zero or more `BreakingChangeFinding` records.

## 2. ModuleVersionContext

| Field | Type | Required | Description | Validation |
|---|---|---:|---|---|
| `ModuleName` | `string` | Yes | Module name copied from the request | Must match `AnalysisRequest.ModuleName` |
| `ResolvedTargetVersion` | `string` | Yes | Target module version under evaluation | Must be analyzable |
| `BaselineVersion` | `string` | Yes | Prior module version used as the comparison baseline | Must be analyzable |
| `TargetModulePath` | `string` | Yes | Absolute path to the cached target module files | Must exist in the temp cache |
| `BaselineModulePath` | `string` | Yes | Absolute path to the cached baseline module files | Must exist in the temp cache |
| `ExportedCommands` | `array<CommandSignature>` | Yes | Public commands exported by the target version | Serialized from isolated inspection |
| `BaselineCommands` | `array<CommandSignature>` | Yes | Public commands exported by the baseline version | Serialized from isolated inspection |

## 3. CommandSignature

| Field | Type | Required | Description |
|---|---|---:|---|
| `Name` | `string` | Yes | Exported command name |
| `CommandType` | `enum(Function, Cmdlet, Alias)` | Yes | Export type |
| `ModuleName` | `string` | Yes | Owning module |
| `ParameterSets` | `array<ParameterSetSignature>` | Yes | Parameter-set definitions exposed to callers |
| `Aliases` | `array<string>` | No | Alternate exported names |

## 4. ParameterSetSignature

| Field | Type | Required | Description |
|---|---|---:|---|
| `Name` | `string` | Yes | Parameter set name |
| `Parameters` | `array<ParameterSignature>` | Yes | Parameters available in this set |
| `IsDefault` | `bool` | Yes | Indicates the default parameter set |

## 5. ParameterSignature

| Field | Type | Required | Description |
|---|---|---:|---|
| `Name` | `string` | Yes | Parameter name without `-` |
| `IsMandatory` | `bool` | Yes | Whether the parameter is mandatory |
| `Position` | `int?` | No | Positional binding index if defined |
| `TypeName` | `string` | No | PowerShell/.NET type name when available |
| `Aliases` | `array<string>` | No | Parameter aliases |

## 6. BreakingChangeDescriptor

| Field | Type | Required | Description | Validation |
|---|---|---:|---|---|
| `ChangeId` | `string` | Yes | Stable identifier for the derived change | Unique within a run |
| `ChangeType` | `enum(RemovedCommand, RemovedAlias, RemovedParameter, MandatoryParameterAdded, CommandMissingFromTarget)` | Yes | Structural breaking-change category | Limited to MVP-supported types |
| `CommandName` | `string` | Yes | Affected command |
| `ParameterName` | `string?` | No | Affected parameter when applicable | Required for parameter categories |
| `Severity` | `enum(Critical, High, Medium)` | Yes | Risk level surfaced in reports | Determined by category |
| `BaselineVersion` | `string` | Yes | Version where the surface existed | Must match context baseline |
| `TargetVersion` | `string` | Yes | Version where the surface changed or disappeared | Must match context target |
| `Explanation` | `string` | Yes | Human-readable reason the change is risky | Non-empty |
| `SuggestedRemediation` | `string?` | No | Default remediation guidance | Optional but recommended |

## 7. CodeReference

| Field | Type | Required | Description | Validation |
|---|---|---:|---|---|
| `FilePath` | `string` | Yes | Absolute path to the analyzed file | Must be under `TargetPath` |
| `LineNumber` | `int` | Yes | 1-based source line | Must be > 0 |
| `ColumnNumber` | `int` | Yes | 1-based source column | Must be > 0 |
| `SourceText` | `string` | Yes | Exact AST extent or matched line text | Non-empty |
| `InvocationKind` | `enum(Command, Parameter, ModuleQualifiedCommand, ImportStatement)` | Yes | How the module usage was detected | Derived from parser output |

## 8. BreakingChangeFinding

| Field | Type | Required | Description |
|---|---|---:|---|
| `FindingId` | `string` | Yes | Stable per-run finding identifier |
| `RequestId` | `guid` | Yes | Parent analysis request |
| `Descriptor` | `BreakingChangeDescriptor` | Yes | Structural change matched in code |
| `Reference` | `CodeReference` | Yes | Where the risky usage was found |
| `Confidence` | `enum(High, Medium)` | Yes | AST matches are `High`; regex fallback matches are `Medium` |
| `Evidence` | `string` | Yes | Explanation linking source usage to the derived change |

## 9. AnalysisResult

| Field | Type | Required | Description | Validation |
|---|---|---:|---|---|
| `RequestId` | `guid` | Yes | Parent request id | Must match `AnalysisRequest.RequestId` |
| `Status` | `enum(CompletedWithFindings, CompletedWithoutFindings, FailedValidation, FailedAnalysis)` | Yes | Overall run outcome | One terminal status per request |
| `ResolvedTargetVersion` | `string` | Yes | Version label echoed to the user | Must match request |
| `BaselineVersion` | `string` | Yes | Baseline label echoed to the user | Must match request |
| `FindingCount` | `int` | Yes | Number of findings in the result | `>= 0` |
| `AffectedFileCount` | `int` | Yes | Number of unique files with findings | `>= 0` |
| `Findings` | `array<BreakingChangeFinding>` | Yes | Detailed findings | Empty when no findings or validation failure |
| `Warnings` | `array<string>` | No | Non-fatal analysis warnings | Optional |
| `Errors` | `array<AnalysisError>` | No | Validation or runtime errors | Required for failed states |
| `DurationMs` | `int` | Yes | End-to-end execution time | `>= 0` |

## 10. AnalysisError

| Field | Type | Required | Description |
|---|---|---:|---|
| `ErrorId` | `string` | Yes | Stable programmatic id such as `InvalidTargetPath` |
| `Category` | `string` | Yes | PowerShell `ErrorCategory` name |
| `Message` | `string` | Yes | User-facing explanation |
| `RecommendedAction` | `string` | Yes | Recovery guidance |

## State Transitions

```text
Received
  -> ValidatingInput
  -> ResolvingTargetVersion
  -> ExportingModuleSurface
  -> DiscoveringTargetFiles
  -> ScanningSource
  -> MatchingFindings
  -> CompletedWithFindings | CompletedWithoutFindings

Received
  -> ValidatingInput
  -> FailedValidation

ResolvingTargetVersion | ExportingModuleSurface | DiscoveringTargetFiles | ScanningSource
  -> FailedAnalysis
```

## Design Notes

- Results are immutable snapshots of one run so reviewers can reproduce outputs against the same target and baseline versions.
- The `BaselineVersion` remains a first-class field to make the derived comparison auditable even though it is resolved internally.
- Confidence is explicit because AST-driven findings and regex-fallback findings do not have the same reliability profile.
