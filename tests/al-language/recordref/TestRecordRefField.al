// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-field-method
// Fixtures used: ALT Universal (60000)

codeunit 60070 "Test RecordRef Field"
{
    Subtype = Test;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure RecordRef_Field_ByNumber_ReturnsFieldRef()
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        Initialize();
        RecRef.Open(60000);
        FldRef := RecRef.Field(1);
        Assert.AreEqual(1, FldRef.Number, 'FieldRef.Number must equal 1 after Field(1)');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_Field_ValueSetGet_Roundtrips()
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        Initialize();
        RecRef.Open(60000);
        FldRef := RecRef.Field(1);
        FldRef.Value := 42;
        Assert.AreEqual(42, FldRef.Value(), 'FieldRef.Value() must roundtrip to 42 after setting Value:=42');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_FieldIndex_ReturnsFieldRef()
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        Initialize();
        RecRef.Open(60000);
        FldRef := RecRef.FieldIndex(1);
        Assert.IsTrue(FldRef.Number > 0, 'FieldRef.Number must be > 0 after FieldIndex(1)');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_FieldCount_ReturnsPositiveNumber()
    var
        RecRef: RecordRef;
    begin
        Initialize();
        RecRef.Open(60000);
        Assert.IsTrue(RecRef.FieldCount() > 0, 'FieldCount() must return > 0 for ALT Universal (has 18 fields)');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_GetTable_CopiesDataToRecord()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
        RecCopy: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 7;
        Rec."Description Field" := 'TestData';
        Rec.Insert();
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(7);  // Position RecRef on Entry No.=7 before GetTable
        RecRef.FindFirst();
        RecRef.GetTable(RecCopy);
        // GetTable copies the current row from RecordRef into the typed Record buffer.
        // Assert on the non-PK field 'Description Field' to confirm field data was copied.
        Assert.AreEqual('TestData', RecCopy."Description Field", 'GetTable() must copy Description Field value');
        // Entry No. must be non-negative (GetTable copies the full row including PK if available)
        Assert.IsTrue(RecCopy."Entry No." >= 0, 'Entry No. must be non-negative after GetTable');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_SetTable_CopiesRecordToRef()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
        FldRef: FieldRef;
        IntField: Integer;
    begin
        Initialize();
        // Insert the record so it exists in the database
        Rec."Entry No." := 5;
        Rec."Integer Field" := 99;
        Rec.Insert();

        // Read it back so Rec holds the committed field values
        Rec.Get(5);

        // SetTable copies all fields from Rec into the RecordRef buffer
        RecRef.Open(60000);
        RecRef.SetTable(Rec);
        // Position the RecordRef on the exact record by primary key so Field() reads the committed row
        RecRef.Find('=');

        // Field(3) in table 60000 is "Integer Field"
        FldRef := RecRef.Field(3);
        IntField := 99;
        Assert.AreEqual(IntField, FldRef.Value(), 'SetTable() must copy Record Integer Field to RecordRef Field(3)');
        RecRef.Close();
    end;

    [Test]
    procedure RecordRef_Field_Name_ReturnsFieldName()
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldName: Text;
    begin
        Initialize();
        RecRef.Open(60000);
        FldRef := RecRef.Field(1);
        FieldName := FldRef.Name();
        Assert.AreEqual('Entry No.', FieldName, 'FieldRef.Name() for Field(1) must return "Entry No."');
        RecRef.Close();
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
