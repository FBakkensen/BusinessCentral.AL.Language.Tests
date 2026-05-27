# Design: Cross-App Tableextension Visibility + Method Dispatch Tests

**Date:** 2026-05-27
**Status:** Approved

---

## Goal

Add two sets of AL tests that reproduce specific BC Runner failure modes so they become executable specs the runner must pass:

**A — Tableextension field visibility across app boundaries**
A test app must be able to read and write fields that a dependency app's tableextension added to a standard BC table. Targets the symbol-merge bug that produced 37× AL0132 / 55× AL0133 in the runner until `.app`-based `SymbolReference.json` routing was fixed.

**B — Cross-app method dispatch by function ID**
A test codeunit calls methods via three distinct dispatch paths — self, dependency codeunit, cross-app interface — and asserts concrete non-default return values. Targets `NavNCLCompilationException: Function ID <hash> … object <id> does not have a member with that ID`.

---

## Architecture

Two existing apps, one new dependency for the fixture app:

```
al-language-internals-fixture/   (App-1, published first)
    app.json                     ← add Base Application dependency
    ALTInternalTable.al          (existing)
    ALTInternalCodeunit.al       (existing)
    ALTItemJournalBatchExt.TableExt.al   ← NEW: tableextension on "Item Journal Batch"
    ALTCrossAppInterface.al              ← NEW: IALTCrossCompute + ALT Cross Compute

al-language/                     (App-2, depends on App-1)
    tableextension/
        TestTableExtCrossApp.al          ← NEW: Part A tests (codeunit 60203)
    codeunit/
        TestCrossAppDispatch.al          ← NEW: Part B tests (codeunit 60204)
```

CI already publishes App-1 before App-2 via `app_dirs` / `test_app_dirs` in `ci.yml`.

A `tests/al.code-workspace` file lets `al-compile` find `al-language/.alpackages` (which contains `Base Application.app`) when compiling the fixture app locally.

---

## Part A: Tableextension Cross-App Field Visibility

### Fixture app changes

**`ALTItemJournalBatchExt.TableExt.al`** — tableextension object ID 61002:
- Extends `"Item Journal Batch"` (table 232, from BC Base Application)
- Adds field 50000 `"ALT Foo"` (Integer, DataClassification = SystemMetadata)
- Adds field 50001 `"ALT Bar"` (Text[50], DataClassification = SystemMetadata)

**`app.json`** — add to `dependencies`:
```json
{
  "id": "437dbf0e-84ff-417a-965d-ed2bb9650972",
  "name": "Base Application",
  "publisher": "Microsoft",
  "version": "27.0.0.0"
}
```

### Test codeunit: `TestTableExtCrossApp.al` (60203)

Located in `tests/al-language/tableextension/`.

**`Initialize()`** calls `Cleanup.Initialize()` then deletes all "Item Journal Batch" records where `"Journal Template Name" = 'ALT'`.

**Tests:**

| Procedure | Claim |
|-----------|-------|
| `TableExt_CrossApp_FooField_InsertAndGet_RoundTrips` | Insert batch with `"ALT Foo" = 42`, Get by PK `('ALT', 'BATCH1')`, assert `"ALT Foo" = 42` |
| `TableExt_CrossApp_BothFields_PersistAfterModify` | Insert, Modify both fields to new values, FindFirst, assert both new values |
| `TableExt_CrossApp_SetRange_OnExtField_FiltersRecords` | Insert two batches (ALT Foo = 10 and 20), SetRange("ALT Foo", 10, 10), assert Count = 1 |
| `TableExt_CrossApp_DuplicateInsert_Throws` | Insert batch with PK `('ALT', 'BATCH1')`, asserterror inserting same PK again — proves extension fields are live on the table (not phantom symbols) |

All records use `"Journal Template Name" = 'ALT'` so local cleanup is deterministic.

---

## Part B: Cross-App Method Dispatch

### Fixture app changes

**`ALTCrossAppInterface.al`** — two objects in one file:
- Interface `IALTCrossCompute` (ID 61003): single method `Evaluate(X: Integer): Integer`
- Codeunit `ALT Cross Compute` (ID 61004): implements `IALTCrossCompute`, returns `X * 3`

Access = Public (default) so the test app can instantiate and use it.

### Test codeunit: `TestCrossAppDispatch.al` (60204)

Located in `tests/al-language/codeunit/`.

Has a local private `Double(X: Integer): Integer` that returns `X * 2`.

**Tests:**

| Procedure | Dispatch path | Claim |
|-----------|---------------|-------|
| `CrossApp_SelfMethod_DirectCall_ReturnsConcreteValue` | self | Calls `Double(7)`, asserts 14 |
| `CrossApp_DepCU_Compute_ReturnsConcreteValue` | dependency codeunit | Calls `ALT Internal Codeunit.Compute(21)`, asserts 42 |
| `CrossApp_Interface_CrossAppDispatch_ReturnsConcreteValue` | cross-app interface | Creates `ALT Cross Compute`, assigns to `IALTCrossCompute`, calls `Evaluate(5)`, asserts 15 |

---

## Cleanup Strategy

- "Item Journal Batch" records are cleaned up in the test codeunit's local `Initialize()` using a filter on `"Journal Template Name" = 'ALT'`, not in the shared `ALTFixtureCleanup`. This keeps cleanup responsibility local to the test that owns the standard-table records.
- `ALT Cross Compute` and `IALTCrossCompute` have no state; no cleanup needed.

---

## Object IDs

| Object | Type | App | ID |
|--------|------|-----|----|
| ALTItemJournalBatchExt | tableextension | fixture | 61002 |
| IALTCrossCompute | interface | fixture | 61003 |
| ALT Cross Compute | codeunit | fixture | 61004 |
| TestTableExtCrossApp | codeunit | test | 60203 |
| TestCrossAppDispatch | codeunit | test | 60204 |

---

## Out of Scope

- Source-only dependency variant (no prebuilt `.app`) — noted as a harder runner gap to cover in a separate issue; not part of this spec.
- Tableextension trigger tests (OnInsert/OnModify on the extension) — deferred; the field-access scenario is the primary reproducer.
- RecordRef/FieldRef access to extension fields — deferred.
