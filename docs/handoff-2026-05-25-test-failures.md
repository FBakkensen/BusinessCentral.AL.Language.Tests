# Handoff: Fix 162 failing AL Language Tests

**Date:** 2026-05-25  
**Repo:** https://github.com/StefanMaron/BusinessCentral.AL.Language.Tests  
**Branch:** master  
**Status:** CI is green on compile + publish, 162/1670 test procedures fail on both BC 27.5 and BC 28.1

---

## What this repo is

An executable specification that proves AL language features work correctly in BC Cloud.
Every `[Test]` procedure is a behavioral contract. Source lives in `tests/al-language/`.
Tests run via the bc-linux reusable workflow (`StefanMaron/MsDyn365Bc.On.Linux`).

---

## How we discovered the failures

The local Python runner `tests/al-language/run-bc-tests.py` was **silently reporting false positives**.
The BC test framework catches `[Test]` procedure failures internally and continues — the codeunit
completes with `status = "Finished"` even when individual procedures fail. The script only fetched
failure details when `status == "Error"` or `"failed"` appeared in `LastResult`. Neither condition
is true for procedure-level failures, so every codeunit was reported as PASS.

**This is now fixed** (commit on 2026-05-25): the runner always fetches log entries.

## Recommended local dev workflow change

**Ditch the Python runner for local testing. Use bc-linux's `run-tests.sh` directly** — it's the
same script CI uses and produces JUnit XML with proper per-procedure pass/fail.

```bash
# Assuming bc-linux is checked out at ~/Documents/Repos/community/bc-linux
# and the .app is built locally via al-compile / al-publish

~/Documents/Repos/community/bc-linux/scripts/run-tests.sh \
  --app tests/al-language/build/al-language.app \
  --codeunit-range 60000..60999 \
  --junit-output /tmp/results.xml \
  --timeout 30
```

The Python script is now only needed to **discover and trigger** codeunit runs via the REST API.
The `run-tests.sh` approach is authoritative.

---

## CI state

- `.github/workflows/ci.yml` runs a matrix over BC 27.5 and BC 28.1
- Both legs compile, publish, and reach the test step successfully
- Both legs fail with the **same 162 failures** (failures are not version-specific)
- JUnit artifacts are uploaded per run as `junit-test-results-{bc_version}`
- Download with: `gh run download <run-id> --repo StefanMaron/BusinessCentral.AL.Language.Tests --dir /tmp/al-junit`

---

## The 162 failures — categorized

All 162 failures are identical on BC 27.5 and BC 28.1.  
Failures are **bugs in the tests**, not BC regressions.

### Category A — 1-based indexing (AL) assumed to be 0-based (~25 failures)

AL's `Text.Substring`, `Text.IndexOf`, `Text.IndexOfAny`, `Text.LastIndexOf`,
`TextBuilder.Insert`, `TextBuilder.Remove` are all **1-based**. Tests were written
with .NET/C# 0-based assumptions.

Key rules:
- `'hello'.Substring(1)` = `'hello'` (position 1 = first char, 1-based)
- `'hello'.Substring(2)` = `'ello'`
- `'hello'.IndexOf('ll')` = `3` (position 3, 1-based), NOT `2`
- `IndexOf` returns **0** when not found, NOT `-1`
- `TextBuilder.Insert(1, 'e')` inserts BEFORE position 1 (prepends), not after position 0
- `TextBuilder.Remove(1, 2)` removes 2 chars starting at position 1 (removes first 2 chars)
- `Text.Split(chars)` takes an `Array of [Char]`, not a comma-separated string

**Affected codeunits:** 60088, 60119, 60157, 60191

**Fix approach:** Read AL docs. Rewrite each test with correct 1-based expectations.
For `IndexOf` "not found" → expect `0`, not `-1`.

---

### Category B — Duration type is not Integer (~9 failures)

Tests compare a `Duration` value to an `Integer` (milliseconds). AL's `Assert.AreEqual`
rejects cross-type comparisons.

```
Expected:<3600000> (Integer). Actual:<1 hour> (Duration)
Expected:<86400000> (Integer). Actual:<1 day> (Duration)
```

Duration arithmetic: `DT2 - DT1` gives a `Duration`, not an `Integer`.
To get milliseconds: assign Duration to Integer or use `Duration / 1`.

**Affected codeunits:** 60162, 60184

**Fix approach:** Either compare `Duration` to `Duration` (use a Duration literal),
or extract ms via integer division: `DurMs := Duration div 1` (no, this won't work).
Actually: declare a Duration variable, assign the ms value, compare Duration to Duration.
Example: `ExpectedDur := 3600000; Assert.AreEqual(ExpectedDur, ActualDur, ...)`.
Or compare to the result of `CreateDateTime` arithmetic.

---

### Category C — Auto-increment counter not reset by DeleteAll() (~12 failures)

`ALTFixtureCleanup.DeleteAll()` (called from `Initialize()`) deletes all rows but does **not**
reset the SQL auto-increment sequence. Tests that assume `Entry No. = 1` after cleanup fail
because the counter keeps incrementing across test runs within the same BC session.

```
"already exists Entry No.='1'" — second test inserts with same PK
"Expected:<0> Actual:<5>" — Init() doesn't reset auto-increment field
```

**Affected codeunits:** 60052, 60055, 60057, 60059, 60129, 60152, 60153, 60164, 60172

**Fix approach:** Tests must not assume specific auto-increment values.
- Use `FindFirst()` to get the actual first record, then verify relative to it
- For "duplicate key" failures: the test is inserting without Init() first — add `Init()` call
- For "does not exist Entry No.='10'" — use `FindLast()` to find what actually exists
- For `Record_Init_SetsAllFieldsToDefault` — `Init()` resets non-PK fields; **PK fields reset
  to 0** only if the record was not yet inserted. After Get(), Init() sets PK back to 0 but
  the auto-increment *counter* is still advanced. Test the field value after Init(), not the counter.

---

### Category D — Record.Copy(shareTable:=true) requires both records to be temp (~5 failures)

`Record.Copy(Source, shareTable:=true)` is only supported when both records are temp variables.
In BC Cloud, calling it on real (non-temp) table variables throws:
```
The COPY function can only be used with the shareTable argument set to true if both records are temporary.
```

**Affected codeunits:** 60053, 60129, 60155, 60198

**Fix approach:**
- Move to out-of-scope confirming tests, OR
- Rewrite using temp records: declare both variables as `Record ALT Universal temporary`

---

### Category E — Features not supported in BC Cloud (~10 failures)

These BC runtime calls are not supported in the Cloud sandbox:

| Feature | Error | Codeunits |
|---|---|---|
| `LockTable(Wait:=false)` | "not supported" | 60060, 60176 |
| `Record.Consistent(false)` | transaction inconsistency error | 60060, 60176 |
| `Record.ReadConsistency()` | returns `false` by default (not `true`) | 60060, 60176 |
| `IsolationLevel` enum (ReadIsolation) | "type IsolationLevel is unknown" | 60176 |
| `ExternalSQL` table connection | "no permission" | 60135, 60145 |
| `DataTransfer.UpdateAuditFields` outside upgrade | asserterror not thrown (or wrong error) | 60146 |
| `CopyLinks` | doesn't copy links in Cloud | 60059 |

**Fix approach:**
- `LockTable(Wait:=false)`: write a `_CloudSandbox_Throws` test, move to `out-of-scope/`
- `ReadConsistency()`: the default is `false` — fix the expected value in the test
- `IsolationLevel`: This enum may not exist in the Cloud runtime; one negative test confirming
- `ExternalSQL`: one negative test confirming permission error
- `CopyLinks`: one negative test or remove

---

### Category F — Format() locale differences (~5 failures)

`Format(true)` returns `"Yes"` in AL w1 locale, not `"true"` / `"True"`.
```
Expected:<true> Actual:<yes>
```

**Affected codeunit:** 60090

**Fix approach:** Change expected value to `"Yes"` (or use `FORMAT(true, 0, 2)` which returns
`"1"` — pick the right format parameter for the intended test).

---

### Category G — Integer vs BigInteger type mismatch in assertions (~5 failures)

`Assert.AreEqual(1000000, bigIntegerVar)` fails because AL's assert is type-strict.
BigInteger values show as `(BigInteger)` in the error.
```
Expected:<1000000> (Integer). Actual:<1000000> (BigInteger)
```

**Affected codeunits:** 60066, 60121, 60140

**Fix approach:** Declare the expected value as `BigInteger`: `ExpectedBI: BigInteger; ExpectedBI := 1000000;`
Also: `JsonValue.AsByte` returns a `Char` (shown as character e.g. `'d'` for 100), not an Integer.
Byte/Char values need to be compared to a `Char` variable, not an Integer.

---

### Category H — InOutStream / Blob — stream position not reset (~10 failures)

After writing to an OutStream, the stream position is at the end. Reading from an InStream
on the same Blob without resetting gives empty results.

```
Expected:<Hello World> Actual:<> — stream is at EOF when read starts
```

**Affected codeunits:** 60109, 60110, 60135, 60151, 60167

**Fix approach:** After writing to a Blob via OutStream, call `Blob.CreateInStream(InStr)` again
to get a fresh InStream positioned at the start. The pattern is:
```al
BlobField.CreateOutStream(OutStr);
OutStr.WriteText('Hello World');
BlobField.CreateInStream(InStr);  // fresh InStream from beginning
InStr.ReadText(Result);
```

---

### Category I — FieldRef enum indexing (4 failures)

`FieldRef.GetEnumValueName(Index)` is 0-based (index 0 = first value).
Tests were written as 1-based.
```
GetEnumValueName(1) → returns "Draft" (index 1 = second value)
Expected "Draft" at index 1, got " " at index 0
```

**Affected codeunit:** 60131

**Fix approach:** Use index 0 for first enum value, 1 for second, etc.

---

### Category J — Report / TestPage handler failures (~10 failures)

Report tests using `[ReportHandler]` and TestPage tests fail with:
```
An error occurred and the transaction is stopped. Contact your administrator for further assistance.
```

**Affected codeunits:** 60116, 60133, 60174

**Fix approach:** Investigate individually. Likely causes:
- Missing handler registration (wrong handler attribute)
- The called report/page doesn't exist or throws in setup
- Transaction state issue from previous test in same codeunit

---

### Category K — Miscellaneous API misunderstandings (~20 failures)

| Test | Codeunit | Issue | Fix |
|---|---|---|---|
| `StrPos_EmptySubstring_ReturnsOne` | 60157 | `StrPos('x', '')` returns 0 in AL, not 1 | expect 0 |
| `CopyStr_PositionZero_ReturnsEmptyOrFull` | 60157 | CopyStr position is 1-based, 0 is invalid | use position 1 |
| `SelectStr_IndexZero` / `IndexBeyondCount` | 60157 | SelectStr is 1-based, throws on invalid | write as `asserterror` tests |
| `Next_NegativeSteps` | 60155 | `Next(-1)` returns **negative** steps count in AL | expect -1 not 1 |
| `ForLoop_Variable_AtEndValue_AfterLoop` | 60186 | After `for i := 1 to 5`, `i` equals 5, not 6 | expect 5 |
| `List/Dict assignment is independent copy` | 60150, 60182 | Lists/Dicts are **value types** (deep copy on assign) — **tests are wrong that it's reference** | test IS correct, but current test fails → investigate |
| `FilterGroup2_Survives_FilterGroup0_Reset` | 60168 | FilterGroup semantics wrong | investigate |
| `SecurityFiltering_Default_IsFiltered` | 60175 | Can't compare SecurityFilter type with Assert.AreEqual | use different assertion |
| `BindSubscription` failures | 60146, 60159 | Subscriber codeunit 60015 doesn't have `[EventSubscriber(Manual:=true)]` | add manual binding attribute |
| `GuiAllowed_InTestContext_ReturnsFalse` | 60173 | `GuiAllowed()` returns **true** in test context (BC service tier with test framework) | expect true |
| `Version_Revision_ReturnsRevision` | 60127 | Version is `5.6.7.8`, Revision() returns 8 not 7 — wrong field | fix expected to 8 |
| `XmlAttribute_CreateNamespaceDeclaration_HasPrefixAndUri` | 60134 | Prefix of namespace declaration `xmlns:ns` is `xmlns`, not `ns` | expect `xmlns` |
| `Variant_IsXmlNode_ReturnsTrue` | 60139 | Need to assign actual XmlNode, not XmlElement | assign via XmlNode variable |
| `Session_ApplicationIdentifier_ReturnsNonNullGuid` | 60122, 60143 | Returns empty GUID or non-standard format | don't try to create Guid from it — just check `<> ''` |
| `Round(2.5)` = 2.5 not 3 | 60142 | AL's Round uses "round half to even" (banker's rounding) by default | expect 2 or use `Round(2.5, 1, '>')` |
| `CopyArray length mismatch` | 60135 | CopyArray destination and source must have compatible lengths | fix array size |
| `TryFunction_RecordInsert_Persists_AfterFailure` | 60166 | Investigate exact TryFunction/commit semantics | read the error, fix logic |
| `InitValue_Insert_Without_Init` | 60195 | InitValue fields are applied by Init(), test logic wrong | re-read what InitValue does |
| `OnInsert_Throws_RecordNotInserted` | 60156 | Trigger error doesn't prevent insert in all cases (Cloud vs local) | investigate |
| `CopyStream` | 60135 | Same stream position issue as Category H | fix stream position |

---

## Summary count by category

| Category | Failures | Effort |
|---|---|---|
| A — 1-based indexing | ~25 | Low — mechanical fixes |
| B — Duration ≠ Integer | ~9 | Low — change assertion type |
| C — Auto-increment state | ~12 | Medium — rethink test design |
| D — Copy(shareTable:=true) non-temp | ~5 | Low — use temp or out-of-scope |
| E — Not supported in Cloud | ~10 | Low — negative tests or remove |
| F — Format() locale | ~2 | Trivial |
| G — Integer vs BigInteger | ~5 | Low |
| H — Stream position | ~10 | Low — fix stream pattern |
| I — FieldRef enum indexing | 4 | Trivial |
| J — Report/TestPage handlers | ~10 | Medium — needs investigation |
| K — Misc API misunderstandings | ~20 | Mixed |
| **Total** | **162** | |

---

## Open bc-linux issue

`preprocessor_symbols` is disabled in our CI. The BC 28 NuGet package is extracted raw
(not a dotnet global tool), and raw `alc` v17.0.34.45391 rejects `/preprocessorsymbols`
with `AL1009`. This is a bc-linux bug. We have no `#if`-gated code yet so this doesn't
block us. Re-enable `preprocessor_symbols` in `.github/workflows/ci.yml` once bc-linux
fixes the nupkg extraction path.

---

## Files to work on in this session

| File | What to fix |
|---|---|
| `tests/al-language/text/TestTextSubstringAndSearch.al` (codeunit 60119) | All 12 indexing bugs |
| `tests/al-language/text/TestTextBuilderOps.al` (codeunit 60088) | Insert/Remove 1-based |
| `tests/al-language/text/TestTextFunctions.al` (codeunit 60157) | StrPos, CopyStr, SelectStr, IndexOf |
| `tests/al-language/language-syntax/TestLoopContracts.al` (codeunit 60186) | ForLoop variable at end |
| `tests/al-language/language-syntax/TestOperatorContracts.al` (codeunit 60191) | Substring/IndexOf |
| `tests/al-language/datetime/TestDurationContracts.al` (codeunit 60184) | Duration vs Integer |
| `tests/al-language/datetime/TestDateTimeContracts.al` (codeunit 60162) | Duration subtraction |
| `tests/al-language/streams/TestInOutStreamContracts.al` (codeunit 60109) | Stream position |
| `tests/al-language/streams/TestStreamFunctions.al` (codeunit 60151, 60167) | Stream position |
| `tests/al-language/streams/TestBlobContracts.al` (codeunit 60110) | Stream position |
| `tests/al-language/record/TestRecordInit.al` (codeunit 60059, 60129, 60195) | Init + auto-increment |
| `tests/al-language/record/TestRecordState.al` (codeunit 60155, 60164) | Copy shareTable + state |
| `tests/al-language/record/TestRecordTransferFields.al` (codeunit 60064) | ALT Base fixture issue |
| `tests/al-language/record/TestAutoIncrement.al` (codeunit 60152, 60172) | Auto-increment assumptions |
| `tests/al-language/record/TestRecordFilters.al` (codeunit 60168) | FilterGroup semantics |
| `tests/al-language/json/TestJsonContracts.al` (codeunit 60121, 60140) | BigInteger/Byte types, missing key |
| `tests/al-language/xml/TestXmlContracts.al` (codeunit 60107, 60134, 60141) | XmlElement.Add, namespace, doctype |
| `tests/al-language/record/TestRecordRef.al` (codeunit 60067, 60070, 60147) | RecordRef open/close, GetTable/SetTable |
| `tests/al-language/record/TestFieldRef.al` (codeunit 60131) | Enum indexing 0-based |
| `tests/al-language/format/TestFormatContracts.al` (codeunit 60090) | Format(true) = "Yes" |
| `tests/al-language/system/TestVariantContracts.al` (codeunit 60095, 60123, 60139) | IsText, IsEnum, IsXmlNode |
| `tests/al-language/system/TestSystemMath.al` (codeunit 60142) | Round banker's rounding |
| `tests/al-language/events/TestEventContracts.al` (codeunit 60146, 60159) | BindSubscription manual |
| `tests/al-language/codeunit/TestCodeunitRun.al` (codeunit 60078, 60190) | Codeunit.Run transaction |
| `tests/al-language/record/TestRecordLocking.al` (codeunit 60060, 60176) | Cloud-unsupported features |

---

## How to run tests locally (correct approach)

```bash
# 1. Start BC
cd ~/Documents/Repos/community/bc-linux && docker compose up -d --wait

# 2. Compile and publish (from repo root)
cd ~/Documents/Repos/community/BusinessCentral.AL.Language
al-compile   # compiles tests/al-language → build/al-language.app
bc-publish   # publishes to local BC

# 3. Run tests with JUnit output (same as CI)
~/Documents/Repos/community/bc-linux/scripts/run-tests.sh \
  --app tests/al-language/build/al-language.app \
  --codeunit-range 60000..60999 \
  --junit-output /tmp/al-results.xml \
  --timeout 30

# 4. Parse failures
python3 -c "
import xml.etree.ElementTree as ET, pathlib
tree = ET.parse('/tmp/al-results.xml')
for tc in tree.getroot().iter('testcase'):
    n = tc.find('failure') or tc.find('error')
    if n is not None:
        print(tc.get('name'), '--', (n.get('message') or '')[:100])
"
```

The Python runner (`run-bc-tests.py`) is now fixed to detect procedure-level failures,
but `run-tests.sh` is the canonical runner that matches CI output exactly.
