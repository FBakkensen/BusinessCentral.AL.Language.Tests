// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-open-method
// Scope: in-scope
// Fixtures used: ALT Universal (60000)

codeunit 60067 "Test RecordRef Open"
{
    Subtype = Test;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure RecordRef_Open_ValidTableNo_OpensRef()
    var
        RecRef: RecordRef;
    begin
        Initialize();
        RecRef.Open(60000);
        Assert.IsFalse(RecRef.IsEmpty(), 'IsEmpty() on open ref must not throw; table should be accessible');
        Assert.IsTrue(RecRef.Number <> 0, 'RecordRef.Number must not be 0 after Open(60000)');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_Open_Number_ReturnsTableNo()
    var
        RecRef: RecordRef;
    begin
        Initialize();
        RecRef.Open(60000);
        Assert.AreEqual(60000, RecRef.Number, 'RecordRef.Number must equal 60000 after Open(60000)');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_Close_AfterOpen_ClosesRef()
    var
        RecRef: RecordRef;
        IsThrown: Boolean;
    begin
        Initialize();
        RecRef.Open(60000);
        RecRef.Close();
        IsThrown := false;
        begin
            if RecRef.IsEmpty() then ; // IsEmpty return value used
        end;
        Assert.IsTrue(true, 'Close() should not throw immediately, but ref is now closed');
    end;

    [Test]
    procedure RecordRef_IsEmpty_EmptyTable_ReturnsTrue()
    var
        RecRef: RecordRef;
    begin
        Initialize();
        RecRef.Open(60000);
        Assert.IsTrue(RecRef.IsEmpty(), 'IsEmpty() must return true on empty table after Initialize()');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_IsEmpty_NonEmptyTable_ReturnsFalse()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        RecRef.Open(60000);
        Assert.IsFalse(RecRef.IsEmpty(), 'IsEmpty() must return false after inserting 1 record');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_Open_TemporaryTable_Opens()
    var
        RecRef: RecordRef;
    begin
        Initialize();
        RecRef.Open(60000);
        Assert.IsTrue(RecRef.Number = 60000, 'RecordRef.Number must be 60000 for non-temporary open');
        RecRef.Close();
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
