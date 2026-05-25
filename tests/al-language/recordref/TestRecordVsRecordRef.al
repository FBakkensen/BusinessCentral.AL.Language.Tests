codeunit 60147 "Test Record vs RecordRef"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure RecordVsRecordRef_Insert_ProducesSameRecord()
    var
        Readback: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert via RecordRef
        RecRef.Open(60000);
        RecRef.Init();
        RecRef.Field(1).Value := 1;  // Entry No.
        RecRef.Field(3).Value := 42;  // Integer Field
        RecRef.Field(6).Value := 'hello';  // Text Field
        RecRef.Insert();

        // Read back via Record and verify
        Assert.IsTrue(Readback.Get(1), 'Record inserted via RecordRef must be findable via Record.Get');
        Assert.AreEqual(42, Readback."Integer Field", 'Integer Field inserted via RecordRef must match');
        Assert.AreEqual('hello', Readback."Text Field", 'Text Field inserted via RecordRef must match');
    end;

    [Test]
    procedure RecordVsRecordRef_Modify_ProducesSameResult()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert via Record
        Rec."Entry No." := 2;
        Rec."Integer Field" := 10;
        Rec.Insert();

        // Modify via RecordRef
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(2);
        RecRef.FindFirst();
        RecRef.Field(3).Value := 99;  // Integer Field
        RecRef.Modify();

        // Read back via Record and verify
        Rec.Get(2);
        Assert.AreEqual(99, Rec."Integer Field", 'Integer Field modified via RecordRef must match');
    end;

    [Test]
    procedure RecordVsRecordRef_Delete_ProducesSameResult()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert via Record
        Rec."Entry No." := 3;
        Rec."Integer Field" := 25;
        Rec.Insert();

        // Delete via RecordRef
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(3);
        RecRef.FindFirst();
        RecRef.Delete();

        // Verify via Record.Get
        Assert.IsFalse(Rec.Get(3), 'Record deleted via RecordRef must not be found via Record.Get');
    end;

    [Test]
    procedure RecordVsRecordRef_Count_Agrees()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
        i: Integer;
    begin
        Initialize();

        // Insert 5 records via Record
        for i := 1 to 5 do begin
            Rec."Entry No." := i;
            Rec."Integer Field" := i * 10;
            Rec.Insert();
        end;

        // Count via both paths
        RecRef.Open(60000);
        Assert.AreEqual(Rec.Count(), RecRef.Count(), 'Record.Count and RecordRef.Count must agree');
    end;

    [Test]
    procedure RecordVsRecordRef_FindFirst_PositionsSameRecord()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert Entry No 3, 1, 2 (out of order)
        Rec."Entry No." := 3;
        Rec."Integer Field" := 30;
        Rec.Insert();

        Rec."Entry No." := 1;
        Rec."Integer Field" := 10;
        Rec.Insert();

        Rec."Entry No." := 2;
        Rec."Integer Field" := 20;
        Rec.Insert();

        // FindFirst via Record
        Rec.FindFirst();

        // FindFirst via RecordRef
        RecRef.Open(60000);
        RecRef.FindFirst();

        // Both should be on Entry No. 1
        Assert.AreEqual(Rec."Entry No.", RecRef.Field(1).Value(), 'FindFirst must position on same record');
    end;

    [Test]
    procedure RecordVsRecordRef_Filter_CountAgrees()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
        i: Integer;
    begin
        Initialize();

        // Insert 5 records
        for i := 1 to 5 do begin
            Rec."Entry No." := i;
            Rec."Integer Field" := i * 10;
            Rec.Insert();
        end;

        // Filter via Record
        Rec.SetRange("Entry No.", 1, 3);

        // Apply same filter to RecordRef
        RecRef.Open(60000);
        RecRef.SetView(Rec.GetView());

        // Count must agree
        Assert.AreEqual(Rec.Count(), RecRef.Count(), 'Filtered counts must agree');
    end;

    [Test]
    procedure RecordVsRecordRef_GetTable_CopiesFields()
    var
        Rec: Record "ALT Universal";
        Rec2: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert via Record
        Rec."Entry No." := 7;
        Rec."Integer Field" := 55;
        Rec."Text Field" := 'test';
        Rec.Insert();

        // Load via RecordRef and GetTable into Rec2
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(7);
        RecRef.FindFirst();
        RecRef.GetTable(Rec2);

        // Verify fields copied
        Assert.AreEqual(7, Rec2."Entry No.", 'Entry No. must be copied via GetTable');
        Assert.AreEqual(55, Rec2."Integer Field", 'Integer Field must be copied via GetTable');
        Assert.AreEqual('test', Rec2."Text Field", 'Text Field must be copied via GetTable');
    end;

    [Test]
    procedure RecordVsRecordRef_SetTable_ThenInsert()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Populate Record
        Rec."Entry No." := 8;
        Rec."Integer Field" := 77;
        Rec."Text Field" := 'setTable test';

        // Load Record into RecordRef via SetTable
        RecRef.Open(60000);
        RecRef.SetTable(Rec);

        // Verify fields transferred
        Assert.AreEqual(77, RecRef.Field(3).Value(), 'Integer Field must be transferred via SetTable');
        Assert.AreEqual('setTable test', RecRef.Field(6).Value(), 'Text Field must be transferred via SetTable');
    end;

    [Test]
    procedure FieldRef_Modify_PersistsToDB()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert via Record
        Rec."Entry No." := 9;
        Rec."Integer Field" := 0;
        Rec.Insert();

        // Modify via FieldRef
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(9);
        RecRef.FindFirst();
        RecRef.Field(3).Value := 123;  // Integer Field
        RecRef.Modify();

        // Read back via Record
        Rec.Get(9);
        Assert.AreEqual(123, Rec."Integer Field", 'FieldRef value change must persist after RecRef.Modify');
    end;

    [Test]
    procedure RecordVsRecordRef_DeleteAll_BothSeeEmpty()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
        i: Integer;
    begin
        Initialize();

        // Insert 3 records
        for i := 1 to 3 do begin
            Rec."Entry No." := i;
            Rec."Integer Field" := i * 10;
            Rec.Insert();
        end;

        // DeleteAll via RecordRef
        RecRef.Open(60000);
        RecRef.DeleteAll();

        // Verify via Record.Count
        Assert.AreEqual(0, Rec.Count(), 'RecordRef.DeleteAll must be visible to Record.Count');
    end;

    [Test]
    procedure RecordVsRecordRef_Rename_VisibleToBoth()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert via Record
        Rec."Entry No." := 10;
        Rec."Integer Field" := 100;
        Rec.Insert();

        // Rename via RecordRef
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(10);
        RecRef.FindFirst();
        RecRef.Rename(99);

        // Verify old key is gone
        Assert.IsFalse(Rec.Get(10), 'Old key must be gone after RecordRef.Rename');

        // Verify new key exists
        Assert.IsTrue(Rec.Get(99), 'New key must exist after RecordRef.Rename');
    end;

    [Test]
    procedure FieldRef_Value_AllTypes_RoundTrip()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
        InsertedInteger: Integer;
        InsertedText: Text[100];
        InsertedDecimal: Decimal;
        ReadbackDecimal: Decimal;
    begin
        Initialize();

        // Insert with specific values
        InsertedInteger := 54321;
        InsertedText := 'roundtrip text';
        InsertedDecimal := 123.45;

        Rec."Entry No." := 11;
        Rec."Integer Field" := InsertedInteger;
        Rec."Text Field" := InsertedText;
        Rec."Decimal Field" := InsertedDecimal;
        Rec.Insert();

        // Read back via RecordRef and verify each type
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(11);
        RecRef.FindFirst();

        Assert.AreEqual(InsertedInteger, RecRef.Field(3).Value(), 'Integer FieldRef.Value must match');
        Assert.AreEqual(InsertedText, RecRef.Field(6).Value(), 'Text FieldRef.Value must match');
        // Convert Decimal Variant to Decimal for proper comparison
        ReadbackDecimal := RecRef.Field(7).Value();
        Assert.AreEqual(InsertedDecimal, ReadbackDecimal, 'Decimal FieldRef.Value must match');
    end;

    [Test]
    procedure RecordVsRecordRef_SystemId_SameValue()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // Insert via Record
        Rec."Entry No." := 12;
        Rec."Integer Field" := 120;
        Rec.Insert();

        // Get via both paths
        Rec.Get(12);
        RecRef.Open(60000);
        RecRef.Field(1).SetRange(12);
        RecRef.FindFirst();

        // SystemId must match
        Assert.AreEqual(Format(Rec.SystemId), Format(RecRef.Field(RecRef.SystemIdNo()).Value()),
            'SystemId via Record and RecordRef must match');
    end;

    [Test]
    procedure RecordVsRecordRef_IsEmpty_Agrees()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
    begin
        Initialize();

        // After Initialize, both must agree
        RecRef.Open(60000);
        Assert.AreEqual(Rec.IsEmpty(), RecRef.IsEmpty(), 'IsEmpty must agree when table is empty');
        RecRef.Close();

        // Insert one record
        Rec."Entry No." := 13;
        Rec.Insert();

        // Now both must agree again
        RecRef.Open(60000);
        Assert.AreEqual(Rec.IsEmpty(), RecRef.IsEmpty(), 'IsEmpty must agree when table is not empty');
        RecRef.Close();
    end;

    [Test]
    procedure RecordVsRecordRef_FindLast_PositionsSameRecord()
    var
        Rec: Record "ALT Universal";
        RecRef: RecordRef;
        i: Integer;
    begin
        Initialize();

        // Insert Entry No 1, 2, 3
        for i := 1 to 3 do begin
            Rec."Entry No." := i;
            Rec."Integer Field" := i * 10;
            Rec.Insert();
        end;

        // FindLast via Record
        Rec.FindLast();

        // FindLast via RecordRef
        RecRef.Open(60000);
        RecRef.FindLast();

        // Both should be on Entry No. 3
        Assert.AreEqual(Rec."Entry No.", RecRef.Field(1).Value(), 'FindLast must position on same record');
    end;

    local procedure Initialize()
    var
        AltUniversal: Record "ALT Universal";
    begin
        AltUniversal.DeleteAll();
    end;
}
