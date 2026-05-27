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
    procedure TableExt_CrossApp_DuplicateInsert_ReturnsFalse()
    // CLAIM: Insert(false) on a duplicate PK returns false — proves the table (with
    // its extension) is live and enforces PK uniqueness.
    // NOTE: Insert(RunTrigger: Boolean) returns false on duplicate; it does not throw.
    // The no-parameter Insert() variant throws instead.
    var
        Batch: Record "Item Journal Batch";
    begin
        Initialize();
        Batch."Journal Template Name" := 'ALTTEST';
        Batch.Name := 'DUP1';
        Batch."ALT Foo" := 5;
        Batch.Insert(false);

        Assert.IsFalse(Batch.Insert(false), 'Duplicate Insert(false) must return false');
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
