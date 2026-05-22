// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-getbysystemid-method
// Scope: in-scope
// Fixtures used: ALT Universal (60000)

codeunit 60061 "Test Record SystemId"
{
    Subtype = Test;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure Record_GetBySystemId_ExistingSystemId_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
        Fetched: Record "ALT Universal";
        SystemId: Guid;
        Result: Boolean;
    begin
        Initialize();
        SystemId := CreateGuid();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.SystemId := SystemId;
        Rec.Insert(false, true);
        Clear(Fetched);
        Result := Fetched.GetBySystemId(SystemId);
        Assert.IsTrue(Result, 'GetBySystemId with existing SystemId must return true');
    end;

    [Test]
    procedure Record_GetBySystemId_InvalidSystemId_ReturnsFalse()
    var
        Rec: Record "ALT Universal";
        InvalidGuid: Guid;
        Result: Boolean;
    begin
        Initialize();
        InvalidGuid := CreateGuid();
        Result := Rec.GetBySystemId(InvalidGuid);
        Assert.IsFalse(Result, 'GetBySystemId with non-existent SystemId must return false');
    end;

    [Test]
    procedure Record_GetBySystemId_ReturnsCorrectRecord()
    var
        Rec: Record "ALT Universal";
        Fetched: Record "ALT Universal";
        SystemId: Guid;
        ExpectedEntryNo: Integer;
        ExpectedIntField: Integer;
    begin
        Initialize();
        ExpectedEntryNo := 42;
        ExpectedIntField := 99;
        SystemId := CreateGuid();
        Rec."Entry No." := ExpectedEntryNo;
        Rec."Integer Field" := ExpectedIntField;
        Rec.SystemId := SystemId;
        Rec.Insert(false, true);
        Clear(Fetched);
        Fetched.GetBySystemId(SystemId);
        Assert.AreEqual(ExpectedEntryNo, Fetched."Entry No.", 'GetBySystemId must return record with correct Entry No.');
        Assert.AreEqual(ExpectedIntField, Fetched."Integer Field", 'GetBySystemId must return record with correct Integer Field');
    end;

    [Test]
    procedure Record_GetBySystemId_ZeroGuid_ReturnsFalse()
    var
        Rec: Record "ALT Universal";
        ZeroGuid: Guid;
        Result: Boolean;
    begin
        Initialize();
        ZeroGuid := '00000000-0000-0000-0000-000000000000';
        Result := Rec.GetBySystemId(ZeroGuid);
        Assert.IsFalse(Result, 'GetBySystemId with zero Guid must return false');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
