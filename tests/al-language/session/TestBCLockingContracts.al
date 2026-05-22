// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-readisolation-method
// Scope: in-scope

codeunit 60176 "Test BC Locking Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure ReadIsolation_Default_IsCallable()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.ReadIsolation(IsolationLevel::Default);
        Assert.IsTrue(true, 'Setting ReadIsolation::Default must not throw');
    end;

    [Test]
    procedure ReadIsolation_ReadUncommitted_Roundtrips()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.ReadIsolation(IsolationLevel::ReadUncommitted);
        Assert.AreEqual(IsolationLevel::ReadUncommitted, Rec.ReadIsolation(), 'ReadIsolation::ReadUncommitted must roundtrip');
    end;

    [Test]
    procedure ReadIsolation_ReadCommitted_Roundtrips()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.ReadIsolation(IsolationLevel::ReadCommitted);
        Assert.AreEqual(IsolationLevel::ReadCommitted, Rec.ReadIsolation(), 'ReadIsolation::ReadCommitted must roundtrip');
    end;

    [Test]
    procedure ReadIsolation_RepeatableRead_Roundtrips()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.ReadIsolation(IsolationLevel::RepeatableRead);
        Assert.AreEqual(IsolationLevel::RepeatableRead, Rec.ReadIsolation(), 'ReadIsolation::RepeatableRead must roundtrip');
    end;

    [Test]
    procedure ReadIsolation_WithReadUncommitted_FindsCommittedData()
    var
        Rec: Record "ALT Universal";
        Rec2: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1; Rec.Insert(); Commit();
        Rec2.ReadIsolation(IsolationLevel::ReadUncommitted);
        Assert.AreEqual(1, Rec2.Count(), 'With ReadUncommitted isolation, committed data must be visible');
    end;

    [Test]
    procedure ReadConsistency_Default_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Assert.IsTrue(Rec.ReadConsistency(), 'ReadConsistency() must return true by default');
    end;

    [Test]
    procedure ReadConsistency_AfterInsert_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1; Rec.Insert();
        Assert.IsTrue(Rec.ReadConsistency(), 'ReadConsistency() must still return true after Insert');
    end;

    [Test]
    procedure Consistent_SetTrue_DoesNotThrow()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.Consistent(true);
        Assert.IsTrue(true, 'Rec.Consistent(true) must not throw');
    end;

    [Test]
    procedure Consistent_SetFalse_DoesNotThrow()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.Consistent(false);
        Assert.IsTrue(true, 'Rec.Consistent(false) must not throw');
    end;

    [Test]
    procedure LockTable_AllowsSubsequentFind()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1; Rec.Insert();
        Rec.LockTable();
        Assert.IsTrue(Rec.FindFirst(), 'FindFirst must work after LockTable()');
        Assert.AreEqual(1, Rec."Entry No.", 'Record must be findable after LockTable');
    end;

    [Test]
    procedure LockTable_WithWaitFalse_DoesNotThrow()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1; Rec.Insert();
        Rec.LockTable(false, false);
        Assert.IsTrue(true, 'LockTable(false, false) must not throw in single-session context');
    end;

    [Test]
    procedure RecordLevelLocking_ReturnsBoolean()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Assert.IsTrue(true, 'RecordLevelLocking() must be callable: ' + Format(Rec.RecordLevelLocking()));
    end;

    local procedure Initialize()
    begin
        ClearLastError();
        Cleanup.Initialize();
    end;
}
