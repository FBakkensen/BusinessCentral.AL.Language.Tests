// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-init-method
// Scope: in-scope
// Fixtures used: ALT Universal (60000), ALT Triggered (60002), ALT Trigger Log (60003)
//
// CRITICAL BC CONTRACT: xRec and record state transitions
// In BC AL, xRec is a special variable available inside table triggers:
// - In OnModify: Rec = new values, xRec = the record BEFORE the modification
// - BUT: this only works correctly from PAGE triggers, NOT from code!
// - When Rec.Modify() is called from CODE, xRec has the SAME values as Rec (new values)
// - This is a known BC behavior — documented quirk, not a bug
//
// Since xRec cannot be accessed from procedural code, we test the OBSERVABLE consequences:
// - Record state persistence after Modify/Rename/Delete/Insert
// - Trigger execution visibility (what Rec contains when trigger fires)
// - Field value transitions visible to code after trigger execution

codeunit 60179 "Test xRec Contracts"
{
    Subtype = Test;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure OnModify_FieldValue_PersistsNewValue()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 0;
        Rec.Insert();
        Rec.Get(1);
        Rec."Integer Field" := 99;
        Rec.Modify();
        Rec.Get(1);
        Assert.AreEqual(99, Rec."Integer Field", 'After Modify, Rec must contain the NEW field value');
    end;

    [Test]
    procedure OnModify_OldValueNotVisible_AfterModify()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        Rec.Get(1);
        Rec."Integer Field" := 99;
        Rec.Modify();
        Rec.Get(1);
        Assert.AreNotEqual(42, Rec."Integer Field", 'After Modify, old value (42) must NOT be visible via Get');
    end;

    [Test]
    procedure OnValidate_NewValue_IsVisibleInTrigger()
    var
        Triggered: Record "ALT Triggered";
        TrigLog: Record "ALT Trigger Log";
    begin
        Initialize();
        Triggered."Entry No." := 1;
        Triggered.Insert(false);
        Triggered.Validate("Watched Field", 'NewValue');
        TrigLog.SetRange("TriggerName", 'OnValidate');
        Assert.IsTrue(TrigLog.FindFirst(), 'OnValidate trigger must fire');
        Assert.AreEqual('NewValue', TrigLog."NewValue", 'OnValidate trigger must see NEW field value (not old)');
    end;

    [Test]
    procedure OnValidate_OldValue_NotSentToTrigger()
    var
        Triggered: Record "ALT Triggered";
        TrigLog: Record "ALT Trigger Log";
    begin
        Initialize();
        Triggered."Entry No." := 1;
        Triggered."Watched Field" := 'OldValue';
        Triggered.Insert(false);
        Triggered.Get(1);
        Triggered.Validate("Watched Field", 'NewValue');
        TrigLog.SetRange("TriggerName", 'OnValidate');
        Assert.IsTrue(TrigLog.FindFirst(), 'OnValidate trigger must fire');
        Assert.AreNotEqual('OldValue', TrigLog."NewValue", 'OnValidate log must contain new value, not old value');
    end;

    [Test]
    procedure OnInsert_Rec_HasInsertedValues()
    var
        Triggered: Record "ALT Triggered";
        TrigLog: Record "ALT Trigger Log";
    begin
        Initialize();
        Triggered."Entry No." := 7;
        Triggered."Name" := 'Test';
        Triggered.Insert(true);
        TrigLog.SetRange("TriggerName", 'OnInsert');
        Assert.IsTrue(TrigLog.FindFirst(), 'OnInsert trigger must fire');
        Assert.AreEqual(7, TrigLog."SourceEntryNo", 'OnInsert trigger must see Entry No=7 in Rec');
    end;

    [Test]
    procedure OnDelete_Rec_HasDeletedValues()
    var
        Triggered: Record "ALT Triggered";
        TrigLog: Record "ALT Trigger Log";
    begin
        Initialize();
        Triggered."Entry No." := 3;
        Triggered.Insert(false);
        Triggered.Get(3);
        Triggered.Delete(true);
        TrigLog.SetRange("TriggerName", 'OnDelete');
        Assert.IsTrue(TrigLog.FindFirst(), 'OnDelete trigger must fire');
        Assert.AreEqual(3, TrigLog."SourceEntryNo", 'OnDelete trigger must see the deleted Entry No');
    end;

    [Test]
    procedure OnRename_Rec_HasNewKey()
    var
        Triggered: Record "ALT Triggered";
        TrigLog: Record "ALT Trigger Log";
    begin
        Initialize();
        Triggered."Entry No." := 1;
        Triggered.Insert(false);
        Triggered.Get(1);
        Triggered.Rename(99);
        TrigLog.SetRange("TriggerName", 'OnRename');
        Assert.IsTrue(TrigLog.FindFirst(), 'OnRename trigger must fire');
        Assert.AreEqual(99, TrigLog."SourceEntryNo", 'OnRename trigger sees NEW Entry No (99), not old (1)');
    end;

    [Test]
    procedure Rec_AfterRename_PositionedAtNewKey()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        Rec.Get(1);
        Rec.Rename(99);
        Assert.AreEqual(99, Rec."Entry No.", 'Rec."Entry No." must be NEW key after Rename');
        Assert.AreEqual(42, Rec."Integer Field", 'Other field values must be preserved after Rename');
    end;

    [Test]
    procedure Rec_AfterRename_OldKeyNotAccessible()
    var
        Rec: Record "ALT Universal";
        Rec2: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec.Get(1);
        Rec.Rename(2);
        Assert.IsFalse(Rec2.Get(1), 'Old key (1) must NOT be findable after Rename to 2');
        Assert.IsTrue(Rec2.Get(2), 'New key (2) MUST be findable after Rename');
    end;

    [Test]
    procedure Init_ClearsAllFields_BeforeInsert()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 99;
        Rec."Text Field" := 'hello';
        Rec.Init();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec.Get(1);
        Assert.AreEqual(0, Rec."Integer Field", 'After Init + Insert, Integer Field must be default 0');
        Assert.AreEqual('', Rec."Text Field", 'After Init + Insert, Text Field must be default empty');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
