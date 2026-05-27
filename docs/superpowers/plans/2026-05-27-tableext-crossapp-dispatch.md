# Cross-App Tableextension + Method Dispatch Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add AL tests that prove (A) a dependent app can read/write fields added by a dependency app's tableextension, and (B) cross-app method dispatch works via three distinct call paths — reproducing specific BC Runner symbol-merge and function-ID failures as executable specs.

**Architecture:** The existing `al-language-internals-fixture` app (App-1) gains a `tableextension` on "Item Journal Batch" and a new cross-app interface + implementation. The existing `al-language` test app (App-2) gets two new test codeunits that reference these objects. A workspace file enables `al-compile` to resolve packages across both apps locally.

**Tech Stack:** AL Language, Business Central Cloud (BC 27.5+), `al-compile` CLI, BC Docker container for local test execution.

---

## File Map

### Create
- `tests/al.code-workspace` — workspace file so `al-compile` finds packages across both apps
- `tests/al-language-internals-fixture/ALTItemJournalBatchExt.TableExt.al` — tableextension 61002 on "Item Journal Batch"
- `tests/al-language-internals-fixture/ALTCrossAppInterface.al` — interface `IALTCrossCompute` + codeunit 61004 `ALT Cross Compute`
- `tests/al-language/tableextension/TestTableExtCrossApp.al` — codeunit 60203, Part A tests
- `tests/al-language/codeunit/TestCrossAppDispatch.al` — codeunit 60204, Part B tests

### Modify
- `tests/al-language-internals-fixture/app.json` — add Base Application dependency
- `tests/al-language/.alpackages/` — add compiled fixture app here after Task 1

---

## Task 1: Workspace file + Base Application dependency

**Files:**
- Create: `tests/al.code-workspace`
- Modify: `tests/al-language-internals-fixture/app.json`

- [ ] **Step 1: Create the workspace file**

  Create `tests/al.code-workspace`:

  ```json
  {
    "folders": [
      { "path": "al-language-internals-fixture" },
      { "path": "al-language" }
    ]
  }
  ```

  This lets `al-compile` find `tests/al-language/.alpackages/` (which contains Base Application and other BC packages) when compiling the fixture app.

- [ ] **Step 2: Add Base Application dependency to the fixture app**

  Replace the full contents of `tests/al-language-internals-fixture/app.json` with:

  ```json
  {
    "id": "f1e2d3c4-b5a6-7890-fedc-ba9876543210",
    "name": "AL Internals Test Fixture",
    "publisher": "AL Language",
    "version": "1.0.0.0",
    "brief": "Dependency fixture exposing internal objects to the AL Language Coverage Tests app.",
    "description": "",
    "privacyStatement": "",
    "EULA": "",
    "help": "",
    "url": "",
    "logo": "",
    "dependencies": [
      {
        "id": "437dbf0e-84ff-417a-965d-ed2bb9650972",
        "name": "Base Application",
        "publisher": "Microsoft",
        "version": "27.0.0.0"
      }
    ],
    "screenshots": [],
    "internalsVisibleTo": [
      {
        "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        "name": "AL Language Coverage Tests",
        "publisher": "AL Language"
      }
    ],
    "idRanges": [
      {
        "from": 61000,
        "to": 61099
      }
    ],
    "features": [],
    "runtime": "14.0",
    "target": "Cloud"
  }
  ```

- [ ] **Step 3: Compile the fixture app and verify it succeeds**

  ```bash
  cd tests/al-language-internals-fixture
  al-compile
  ```

  Expected: `✓ Compilation succeeded!` with zero errors. The compiler will find `Base Application.app` via the workspace's `al-language/.alpackages/` path.

- [ ] **Step 4: Copy the compiled fixture app into the test app's package cache**

  ```bash
  cp "tests/al-language-internals-fixture/AL Internals Test Fixture_1.0.0.0.app" \
     tests/al-language/.alpackages/
  ```

  This makes the fixture app's symbols available to the test app compiler. Without this step, the test app will fail to resolve objects from the fixture app.

- [ ] **Step 5: Verify the test app still compiles**

  ```bash
  cd tests/al-language
  al-compile
  ```

  Expected: zero errors.

- [ ] **Step 6: Commit**

  The `.alpackages/` directory is gitignored, but individual `.app` files in it are force-tracked (same pattern as Base Application.app etc.). Use `-f` to add the new file:

  ```bash
  git add tests/al.code-workspace tests/al-language-internals-fixture/app.json
  git add -f "tests/al-language/.alpackages/AL Internals Test Fixture_1.0.0.0.app"
  git commit -m "chore: workspace file + Base Application dep for fixture app"
  ```

---

## Task 2: Tableextension on "Item Journal Batch"

**Files:**
- Create: `tests/al-language-internals-fixture/ALTItemJournalBatchExt.TableExt.al`

- [ ] **Step 1: Create the tableextension**

  Create `tests/al-language-internals-fixture/ALTItemJournalBatchExt.TableExt.al`:

  ```al
  // Extends "Item Journal Batch" (table 233) with two test fields.
  // Purpose: prove that a dependent app can read/write fields added by a
  // dependency app's tableextension — the symbol-merge scenario that caused
  // AL0132/AL0133 in the BC Runner.
  tableextension 61002 "ALT Item Journal Batch Ext" extends "Item Journal Batch"
  {
      fields
      {
          field(50000; "ALT Foo"; Integer)
          {
              DataClassification = SystemMetadata;
          }
          field(50001; "ALT Bar"; Text[50])
          {
              DataClassification = SystemMetadata;
          }
      }
  }
  ```

- [ ] **Step 2: Compile the fixture app**

  ```bash
  cd tests/al-language-internals-fixture
  al-compile
  ```

  Expected: zero errors.

- [ ] **Step 3: Update the package cache**

  ```bash
  cp "tests/al-language-internals-fixture/AL Internals Test Fixture_1.0.0.0.app" \
     tests/al-language/.alpackages/
  ```

- [ ] **Step 4: Verify the test app still compiles**

  ```bash
  cd tests/al-language
  al-compile
  ```

  Expected: zero errors (test app doesn't yet reference the new fields, so this is just a regression check).

- [ ] **Step 5: Commit**

  ```bash
  git add tests/al-language-internals-fixture/ALTItemJournalBatchExt.TableExt.al
  git add -f "tests/al-language/.alpackages/AL Internals Test Fixture_1.0.0.0.app"
  git commit -m "feat: tableextension on Item Journal Batch in fixture app"
  ```

---

## Task 3: Cross-app interface and implementing codeunit

**Files:**
- Create: `tests/al-language-internals-fixture/ALTCrossAppInterface.al`

- [ ] **Step 1: Create the interface and implementing codeunit**

  Create `tests/al-language-internals-fixture/ALTCrossAppInterface.al`:

  ```al
  // Interface defined in the fixture (dependency) app.
  // ALT Cross Compute implements it and returns X * 3.
  // Purpose: prove that calling a method through an interface where both the
  // interface definition and the implementing codeunit live in a dependency
  // app works correctly — the cross-app interface dispatch scenario.
  interface IALTCrossCompute
  {
      procedure Evaluate(X: Integer): Integer;
  }

  codeunit 61004 "ALT Cross Compute" implements IALTCrossCompute
  {
      procedure Evaluate(X: Integer): Integer
      begin
          exit(X * 3);
      end;
  }
  ```

- [ ] **Step 2: Compile the fixture app**

  ```bash
  cd tests/al-language-internals-fixture
  al-compile
  ```

  Expected: zero errors.

- [ ] **Step 3: Update the package cache**

  ```bash
  cp "tests/al-language-internals-fixture/AL Internals Test Fixture_1.0.0.0.app" \
     tests/al-language/.alpackages/
  ```

- [ ] **Step 4: Verify the test app still compiles**

  ```bash
  cd tests/al-language
  al-compile
  ```

  Expected: zero errors.

- [ ] **Step 5: Commit**

  ```bash
  git add tests/al-language-internals-fixture/ALTCrossAppInterface.al
  git add -f "tests/al-language/.alpackages/AL Internals Test Fixture_1.0.0.0.app"
  git commit -m "feat: IALTCrossCompute interface + ALT Cross Compute in fixture app"
  ```

---

## Task 4: Part A — Tableextension cross-app field visibility tests

**Files:**
- Create: `tests/al-language/tableextension/TestTableExtCrossApp.al`

- [ ] **Step 1: Create the test file**

  Create `tests/al-language/tableextension/TestTableExtCrossApp.al`:

  ```al
  // BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-ext-object
  // Scope: in-scope (Cloud-compatible, multi-app fixture required)
  // Fixtures used: ALT Item Journal Batch Ext (61002) on "Item Journal Batch" (table 233)
  // BC versions: 27.5+
  //
  // CLAIM: a dependent app can read and write fields that a dependency app's
  // tableextension added to a standard BC table. This exercises the symbol-merge
  // of a tableextension loaded as a compiled .app dependency.

  codeunit 60203 "Test TableExt Cross App"
  {
      Subtype = Test;

      var
          Assert: Codeunit Assert;
          Cleanup: Codeunit ALTFixtureCleanup;

      // ── Field round-trip ─────────────────────────────────────────────────────

      [Test]
      procedure TableExt_CrossApp_FooField_InsertAndGet_RoundTrips()
      // CLAIM: "ALT Foo" (Integer) added by the fixture app's tableextension persists
      // through Insert and is readable via Get from the dependent test app.
      // DOCS: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-ext-object
      var
          Batch: Record "Item Journal Batch";
      begin
          Initialize();
          Batch."Journal Template Name" := 'ALTTEST';
          Batch.Name := 'BATCH1';
          Batch."ALT Foo" := 42;
          Batch.Insert(false);

          Clear(Batch);
          Batch.Get('ALTTEST', 'BATCH1');
          Assert.AreEqual(42, Batch."ALT Foo", 'ALT Foo must round-trip through Insert/Get');
      end;

      [Test]
      procedure TableExt_CrossApp_BothFields_PersistAfterModify()
      // CLAIM: both extension fields ("ALT Foo" and "ALT Bar") persist correctly
      // after a Modify — proves that multiple extension fields all survive the update path.
      var
          Batch: Record "Item Journal Batch";
      begin
          Initialize();
          Batch."Journal Template Name" := 'ALTTEST';
          Batch.Name := 'BATCH2';
          Batch."ALT Foo" := 1;
          Batch."ALT Bar" := 'initial';
          Batch.Insert(false);

          Batch."ALT Foo" := 99;
          Batch."ALT Bar" := 'modified';
          Batch.Modify(false);

          Clear(Batch);
          Batch.Get('ALTTEST', 'BATCH2');
          Assert.AreEqual(99, Batch."ALT Foo", 'ALT Foo must reflect modified value');
          Assert.AreEqual('modified', Batch."ALT Bar", 'ALT Bar must reflect modified value');
      end;

      [Test]
      procedure TableExt_CrossApp_SetRange_OnExtField_FiltersRecords()
      // CLAIM: SetRange on "ALT Foo" (an extension field) narrows the result set,
      // proving filters on extension fields work in the dependent app.
      var
          Batch: Record "Item Journal Batch";
      begin
          Initialize();
          Batch."Journal Template Name" := 'ALTTEST';
          Batch.Name := 'FILTER1';
          Batch."ALT Foo" := 10;
          Batch.Insert(false);

          Clear(Batch);
          Batch."Journal Template Name" := 'ALTTEST';
          Batch.Name := 'FILTER2';
          Batch."ALT Foo" := 20;
          Batch.Insert(false);

          Batch.Reset();
          Batch.SetRange("Journal Template Name", 'ALTTEST');
          Batch.SetRange("ALT Foo", 10, 10);
          Assert.AreEqual(1, Batch.Count(), 'SetRange on ALT Foo must filter to exactly one record');
      end;

      [Test]
      procedure TableExt_CrossApp_DuplicateInsert_Throws()
      // CLAIM: inserting a duplicate PK on "Item Journal Batch" throws — proves the
      // table (with its extension) is live and enforces standard PK uniqueness.
      var
          Batch: Record "Item Journal Batch";
      begin
          Initialize();
          Batch."Journal Template Name" := 'ALTTEST';
          Batch.Name := 'DUP1';
          Batch."ALT Foo" := 5;
          Batch.Insert(false);

          asserterror Batch.Insert(false);
          Assert.IsTrue(GetLastErrorText() <> '', 'Duplicate Insert must throw a runtime error');
      end;

      local procedure Initialize()
      var
          Batch: Record "Item Journal Batch";
      begin
          Cleanup.Initialize();
          Batch.SetRange("Journal Template Name", 'ALTTEST');
          Batch.DeleteAll(false);
      end;
  }
  ```

- [ ] **Step 2: Compile the test app**

  ```bash
  cd tests/al-language
  al-compile
  ```

  Expected: zero errors. The compiler resolves `"ALT Foo"` and `"ALT Bar"` from the fixture app's compiled package in `.alpackages/`.

- [ ] **Step 3: Commit**

  ```bash
  git add tests/al-language/tableextension/TestTableExtCrossApp.al
  git commit -m "feat: Part A — tableextension cross-app field visibility tests (60203)"
  ```

---

## Task 5: Part B — Cross-app method dispatch tests

**Files:**
- Create: `tests/al-language/codeunit/TestCrossAppDispatch.al`

- [ ] **Step 1: Create the test file**

  Create `tests/al-language/codeunit/TestCrossAppDispatch.al`:

  ```al
  // BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-codeunit-object
  // Scope: in-scope
  // Fixtures used: ALT Internal Codeunit (61000), IALTCrossCompute / ALT Cross Compute (61004)
  // BC versions: 27.5+
  //
  // CLAIM: method dispatch works correctly across three call paths:
  //   (a) a method on the calling codeunit itself
  //   (b) a method on a codeunit in a dependency app, called directly
  //   (c) a method called through an interface whose definition and
  //       implementation both live in a dependency app
  // This targets NavNCLCompilationException: Function ID <hash> does not have
  // a member with that ID — the numeric function-ID dispatch bug in the runner.

  codeunit 60204 "Test Cross App Dispatch"
  {
      Subtype = Test;

      var
          Assert: Codeunit Assert;
          Cleanup: Codeunit ALTFixtureCleanup;

      // ── (a) Self-dispatch ────────────────────────────────────────────────────

      [Test]
      procedure CrossApp_SelfMethod_DirectCall_ReturnsConcreteValue()
      // CLAIM: calling a private method defined on this codeunit returns the
      // correct value — baseline that self-dispatch works before testing cross-app.
      begin
          Initialize();
          Assert.AreEqual(14, Double(7), 'Self-dispatch: Double(7) must return 14');
      end;

      // ── (b) Dependency codeunit dispatch ─────────────────────────────────────

      [Test]
      procedure CrossApp_DepCU_Compute_ReturnsConcreteValue()
      // CLAIM: calling a method on ALT Internal Codeunit (defined in the fixture
      // dependency app) returns the correct computed value.
      // This exercises direct call dispatch to a compiled dependency codeunit.
      var
          InternalCU: Codeunit "ALT Internal Codeunit";
      begin
          Initialize();
          Assert.AreEqual(42, InternalCU.Compute(21), 'DepCU dispatch: Compute(21) must return 42');
      end;

      // ── (c) Cross-app interface dispatch ─────────────────────────────────────

      [Test]
      procedure CrossApp_Interface_CrossAppDispatch_ReturnsConcreteValue()
      // CLAIM: calling a method through an interface where both the interface
      // definition (IALTCrossCompute) and the implementing codeunit (ALT Cross Compute)
      // live in the dependency app returns the correct computed value.
      // This exercises interface-table-driven dispatch across the app boundary.
      var
          C: Interface IALTCrossCompute;
          Impl: Codeunit "ALT Cross Compute";
      begin
          Initialize();
          C := Impl;
          Assert.AreEqual(15, C.Evaluate(5), 'Cross-app interface dispatch: Evaluate(5) must return 15');
      end;

      local procedure Double(X: Integer): Integer
      begin
          exit(X * 2);
      end;

      local procedure Initialize()
      begin
          Cleanup.Initialize();
      end;
  }
  ```

- [ ] **Step 2: Compile the test app**

  ```bash
  cd tests/al-language
  al-compile
  ```

  Expected: zero errors. The compiler resolves `IALTCrossCompute` and `"ALT Cross Compute"` from the fixture package.

- [ ] **Step 3: Commit**

  ```bash
  git add tests/al-language/codeunit/TestCrossAppDispatch.al
  git commit -m "feat: Part B — cross-app method dispatch tests (60204)"
  ```

---

## Running Against BC (optional local validation)

After all tasks, publish both apps and run the new test codeunits:

```bash
# 1. Start BC container (from bc-linux repo)
cd ~/Documents/Repos/community/bc-linux && docker compose up -d --wait

# 2. Publish fixture app first
cd tests/al-language-internals-fixture
bc-publish

# 3. Publish + run test app
cd tests/al-language
bc-publish
python3 run-bc-tests.py --ids "60203,60204"
```

Expected: `2 passed, 0 failed`.
