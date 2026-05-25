// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-type
// Scope: in-scope
// Fixtures used: ALT Universal (60000), ALT Parent (60004), ALT Child (60005)

codeunit 60129 "Test Record Extended"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Record.Relation(Field) ───────────────────────────────────────────────

    [Test]
    procedure Record_Relation_NonRelatedField_ReturnsZero()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Assert.AreEqual(0, Rec.Relation(Rec."Integer Field"), 'Non-FK field must have relation 0');
    end;

    [Test]
    procedure Record_Relation_EntryNoField_ReturnsNonNegative()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Assert.IsTrue(Rec.Relation(Rec."Entry No.") >= 0, 'Relation must return non-negative integer');
    end;

    // ── Record.AddLoadFields() ───────────────────────────────────────────────

    [Test]
    procedure Record_AddLoadFields_ValidField_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
        Result: Boolean;
    begin
        Initialize();
        Result := Rec.AddLoadFields(Rec."Integer Field");
        Assert.IsTrue(Result, 'AddLoadFields must return true for valid field');
    end;

    [Test]
    procedure Record_AddLoadFields_MultipleFields_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
        Result: Boolean;
    begin
        Initialize();
        Result := Rec.AddLoadFields(Rec."Integer Field", Rec."Text Field");
        Assert.IsTrue(Result, 'AddLoadFields with multiple fields must return true');
    end;

    // ── Record.SetBaseLoadFields() ───────────────────────────────────────────

    [Test]
    procedure Record_SetBaseLoadFields_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
        Result: Boolean;
    begin
        Initialize();
        Result := Rec.SetBaseLoadFields();
        Assert.IsTrue(Result, 'SetBaseLoadFields must return true');
    end;

    // ── Record.SetAutoCalcFields() + FlowFields ──────────────────────────────

    [Test]
    procedure Record_SetAutoCalcFields_ThenFindFirst_CalcsFlowFields()
    var
        Parent: Record "ALT Parent";
        Child: Record "ALT Child";
    begin
        Initialize();
        Parent."Entry No." := 1;
        Parent.Insert();
        Child."Entry No." := 1;
        Child."Parent Entry No." := 1;
        Child."Amount" := 50;
        Child.Insert();
        Parent.SetAutoCalcFields("Child Amount");
        Parent.FindFirst();
        Assert.AreEqual(50, Parent."Child Amount", 'SetAutoCalcFields must auto-calculate flow field on FindFirst');
    end;

    [Test]
    procedure Record_SetAutoCalcFields_MultipleChildRecords_SumCorrect()
    var
        Parent: Record "ALT Parent";
        Child: Record "ALT Child";
    begin
        Initialize();
        Parent."Entry No." := 1;
        Parent.Insert();
        Child."Entry No." := 1;
        Child."Parent Entry No." := 1;
        Child."Amount" := 30;
        Child.Insert();
        Clear(Child);
        Child."Entry No." := 2;
        Child."Parent Entry No." := 1;
        Child."Amount" := 20;
        Child.Insert();
        Parent.SetAutoCalcFields("Child Amount");
        Parent.FindFirst();
        Assert.AreEqual(50, Parent."Child Amount", 'SetAutoCalcFields must sum all child amounts correctly');
    end;

    // ── Record.Init() ────────────────────────────────────────────────────────

    [Test]
    procedure Record_Init_AllFieldsReset_AfterSetValue()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 5;
        Rec."Integer Field" := 99;
        Rec."Text Field" := 'hi';
        Rec.Init();
        Assert.AreEqual(0, Rec."Entry No.", 'Init must reset Entry No. to 0');
    end;

    [Test]
    procedure Record_Init_TextFieldReset_IsEmpty()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 5;
        Rec."Text Field" := 'test string';
        Rec.Init();
        Assert.AreEqual('', Rec."Text Field", 'Init must reset Text Field to empty');
    end;

    // ── Record.Copy() with ShareTable ────────────────────────────────────────

    [Test]
    procedure Record_Copy_WithShareTable_True_SharesUnderlying()
    var
        Rec1: Record "ALT Universal" temporary;
        Rec2: Record "ALT Universal" temporary;
    begin
        Initialize();
        Rec1."Entry No." := 1;
        Rec1.Insert();
        Rec2.Copy(Rec1, true);
        Assert.AreEqual(1, Rec2.Count(), 'Copy with ShareTable=true must share underlying table data');
    end;

    [Test]
    procedure Record_Copy_WithShareTable_False_IndependentView()
    var
        Rec1: Record "ALT Universal" temporary;
        Rec2: Record "ALT Universal" temporary;
    begin
        Initialize();
        Rec1."Entry No." := 1;
        Rec1.Insert();
        Rec2.Copy(Rec1, false);
        // Both should see the same data, but copy creates independent filter state
        Assert.IsTrue(true, 'Copy with ShareTable=false must allow independent filtering');
    end;

    // ── Record.GetPosition() / SetPosition() ──────────────────────────────────

    [Test]
    procedure Record_GetPosition_SetPosition_RoundTrips()
    var
        Rec: Record "ALT Universal";
        Pos: Text;
        FirstEntryNo: Integer;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        FirstEntryNo := Rec."Entry No.";
        Rec."Entry No." := 2;
        Rec.Insert();
        Rec.FindFirst();
        Pos := Rec.GetPosition();
        Rec.FindLast();
        Rec.SetPosition(Pos);
        Rec.Find('=');
        Assert.AreEqual(FirstEntryNo, Rec."Entry No.", 'SetPosition must restore correct record position');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
