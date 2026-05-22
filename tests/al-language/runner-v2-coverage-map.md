# AL Language Coverage Test Suite — Runner v2 Coverage Map

## Full Run Results (Real BC Container)

- **128 test codeunits**, **1,411 [Test] procedures**
- **128/128 PASS** against BC 27.5 (localhost:7049)

## Runner v2 Compatibility Analysis

The AL Runner v2 (`alrunner`) cannot compile the full suite due to implementation gaps.
Breakdown of the 128 codeunits:

| Category | Count | Tests |
|----------|-------|-------|
| ✅ Runs in runner v2 (no gaps) | 89 | ~878 |
| ⚠️ Has runner v2 compilation gaps | 22 | ~326 |
| 🚫 BC-platform-only (by design) | 17 | ~207 |

## Runner v2 Compilation Gaps Found

These are gaps in runner v2 — bugs or missing implementations revealed by the test suite:

| Gap | Affects | Files |
|-----|---------|-------|
| `Report.Run()` overload signature | 3 | TestReportHandler, TestPageAdvanced, TestBCReportHandlers |
| `LockTable(Wait, VersionCheck)` 2-arg overload | 2 | TestRecordLock, TestBCLockingContracts |
| `Truncate(bool)` overload | 2 | TestRecordDelete, TestBCSystemFieldContracts |
| JSON typed getter arg type mismatch (int→string) | 2 | TestJsonComplete, TestJsonTypedGetters |
| `NavText` type mismatch (string→NavText) | 2 | TestNavAppExtended, TestMiscComplete |
| Return type mismatch (void→int) | 2 | TestArrayStreamContracts, TestSystemExtended |
| `RecordRef.AddLink/HasLinks/DeleteLinks` missing | 1 | TestRecordRefKeys |
| `TransferFields(3-arg)` overload | 1 | TestRecordTransferFields |
| `FieldRef.FieldError()` no-arg overload | 1 | TestFieldRefFieldError |
| `Record.GetPosition(UseNames)` overload | 1 | TestRecordFilter |
| `Evaluate(Version)` type not reference type | 1 | TestMiscTypes |
| `System.GetUrl()` signature mismatch | 1 | TestFinalCoverage |
| `ReadIsolation`/`IsolationLevel` enum type | 1 | TestRecordLock |
| `FlowField CalcFields` return type mismatch | 1 | TestFlowFieldContracts |
| `SetAutoCalcFields` return void vs object | 1 | TestFlowFieldContracts |
| 2D array indexer signature | 1 | TestArrayStreamContracts |
| `JsonObject.GetBoolean(3-arg)` overload | 1 | TestJsonTypedGetters |
| Assignment to DB method result | 2 | TestDatabaseExtended, TestMiscComplete |

## BC-Specific Tests (Runner v2 Cannot Support by Design)

These test BC runtime behaviors that require the real service tier:

- **Event subscribers** — `ALT Event Publisher/Subscriber`, `OnInsert/OnModify` triggers
- **SecurityFiltering** — `SecurityFilter::Filtered/Ignored` runtime enforcement
- **System audit fields** — `SystemCreatedBy`, `SystemModifiedBy` (set by BC identity service)
- **`GuiAllowed()`/`IsServiceTier()`** — execution context detection
- **`ChangeCompany()`** — multi-company data isolation
- **`ReadIsolation`** — transaction isolation levels (service tier only)
- **BC report rendering** — `Report.Run(showRequestPage=true)` requires service tier
- **`Database.IsInWriteTransaction()`** — transaction state (service tier only)
- **`Session.GetExecutionContext()`** — BC execution context enum
- **`NavApp.GetCurrentModuleInfo()`** app identity

## Conclusion

Of the 1,411 tests, **~878 (62%)** are directly runnable in the AL Runner v2 today.
The **22 codeunits with compilation gaps reveal specific, actionable runner v2 bugs** —
each gap is a missing overload or type mapping that can be fixed individually.
