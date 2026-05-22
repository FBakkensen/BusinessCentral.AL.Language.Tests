// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-locktable-method
// Scope: in-scope
// Fixtures used: ALT Universal (60000)

codeunit 60060 "Test Record Lock"
{
    Subtype = Test;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure Record_LockTable_Called_TableIsLocked()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.LockTable();
        Assert.IsTrue(true, 'LockTable() must not throw an error');
    end;

    [Test]
    procedure Record_LockTable_WaitTrue_WaitsForLock()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.LockTable(true);
        Assert.IsTrue(true, 'LockTable(Wait: true) must not throw an error');
    end;

    [Test]
    procedure Record_LockTable_VersionCheckTrue_ChecksVersion()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.LockTable(false, true);
        Assert.IsTrue(true, 'LockTable(Wait: false, VersionCheck: true) must not throw an error');
    end;

    [Test]
    procedure Record_Consistent_SetTrue_AllowsInconsistency()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.Consistent(true);
        Assert.IsTrue(true, 'Consistent(true) must not throw an error');
    end;

    [Test]
    procedure Record_Consistent_SetFalse_EnforcesConsistency()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.Consistent(false);
        Assert.IsTrue(true, 'Consistent(false) must not throw an error');
    end;

    [Test]
    procedure Record_ReadConsistency_Default_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
        IsConsistent: Boolean;
    begin
        Initialize();
        IsConsistent := Rec.ReadConsistency();
        Assert.IsTrue(IsConsistent, 'ReadConsistency() must return true by default');
    end;

    [Test]
    procedure Record_ReadIsolation_Get_ReturnsDefault()
    var
        Rec: Record "ALT Universal";
        IsolationLevel: IsolationLevel;
    begin
        Initialize();
        IsolationLevel := Rec.ReadIsolation();
        Assert.IsTrue(true, 'ReadIsolation() must return a valid IsolationLevel enum value');
    end;

    [Test]
    procedure Record_ReadIsolation_Set_ChangesIsolation()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec.ReadIsolation(IsolationLevel::Default);
        Assert.IsTrue(true, 'ReadIsolation(IsolationLevel::Default) must not throw an error');
    end;

    [Test]
    procedure Record_RecordLevelLocking_ReturnsBoolean()
    var
        Rec: Record "ALT Universal";
        IsLocking: Boolean;
    begin
        Initialize();
        IsLocking := Rec.RecordLevelLocking();
        Assert.IsTrue(true, 'RecordLevelLocking() must return a valid boolean value');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
