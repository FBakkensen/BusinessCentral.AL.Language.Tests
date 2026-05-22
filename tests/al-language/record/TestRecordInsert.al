// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-insert--method
// Scope: in-scope
// Fixtures used: ALT Universal (60000), ALT Triggered (60002)

codeunit 60050 "Test Record Insert"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure Record_Insert_NewRecord_ReturnsTrue()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Insert() no-arg: new record returns true');
    end;

    [Test]
    procedure Record_Insert_DuplicateKey_ReturnsFalse()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Insert() no-arg: duplicate key returns false');
    end;

    [Test]
    procedure Record_Insert_EmptyTable_CountIsOne()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Insert() no-arg: empty table count is one after insert');
    end;

    [Test]
    procedure Record_Insert_RunTriggerTrue_FiresOnInsert()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Insert(RunTrigger: true): fires OnInsert trigger');
    end;

    [Test]
    procedure Record_Insert_RunTriggerFalse_DoesNotFireOnInsert()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Insert(RunTrigger: false): does not fire OnInsert trigger');
    end;

    [Test]
    procedure Record_Insert_InsertWithSystemId_PreservesGuid()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Insert(RunTrigger, InsertWithSystemId: true): preserves provided GUID');
    end;

    [Test]
    procedure Record_Insert_InsertWithNewSystemId_GeneratesGuid()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Insert(RunTrigger, InsertWithSystemId: false): generates new GUID');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
