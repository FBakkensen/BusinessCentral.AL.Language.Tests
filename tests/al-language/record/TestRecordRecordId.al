// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-recordid-method
// Scope: in-scope
// Fixtures used: ALT Universal (60000), ALT Composite (60001)

codeunit 60062 "Test Record RecordId"
{
    Subtype = Test;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure Record_RecordId_InsertedRecord_HasNonEmptyRecordId()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.RecordId() non-empty');
    end;

    [Test]
    procedure Record_RecordId_RecordIdTableNo_MatchesTableId()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.RecordId() table number matches');
    end;

    [Test]
    procedure Record_RecordId_CompositeKey_RecordIdContainsAllKeyFields()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.RecordId() composite key contains all fields');
    end;

    [Test]
    procedure Record_FullyQualifiedName_ReturnsNonEmpty()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.FullyQualifiedName() non-empty');
    end;

    [Test]
    procedure Record_FullyQualifiedName_ContainsTableName()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.FullyQualifiedName() contains table name');
    end;

    [Test]
    procedure Record_TableName_ReturnsCorrectName()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.TableName() correct name');
    end;

    [Test]
    procedure Record_TableCaption_ReturnsCaption()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.TableCaption() returns caption');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
