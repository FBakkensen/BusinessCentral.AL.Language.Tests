// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-triggers-overview
// Scope: in-scope
// Fixtures used: ALT Error Trigger (60023), ALT Universal (60000)
codeunit 60156 "Test Trigger Rollback"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    local procedure Initialize()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        ErrRec.DeleteAll(false);
        Cleanup.Initialize();
    end;

    [Test]
    procedure OnInsert_NoError_InsertSucceeds()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Should Error" := false;
        ErrRec.Insert(true);

        Assert.AreEqual(1, ErrRec.Count(), 'Insert with Should Error=false must succeed');
    end;

    [Test]
    procedure OnInsert_Throws_RecordNotInserted()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Should Error" := true;
        asserterror ErrRec.Insert(true);

        Assert.AreEqual('OnInsert error triggered', GetLastErrorText(), 'asserterror must capture OnInsert error text');
        Assert.AreEqual(0, ErrRec.Count(), 'After OnInsert error, record must NOT be in the table (rolled back)');
    end;

    [Test]
    procedure OnInsert_Throws_ErrorTextContainsMessage()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Should Error" := true;
        asserterror ErrRec.Insert(true);

        Assert.IsTrue(
            StrPos(GetLastErrorText(), 'OnInsert error triggered') > 0,
            'OnInsert error text must be preserved through asserterror'
        );
    end;

    [Test]
    procedure OnModify_Throws_ValueNotModified()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Value" := 10;
        ErrRec."Should Error" := false;
        ErrRec.Insert(false);

        ErrRec.Get(1);
        ErrRec."Should Error" := true;
        ErrRec."Value" := 99;
        asserterror ErrRec.Modify(true);

        Assert.AreEqual('OnModify error triggered', GetLastErrorText(), 'OnModify error text must be captured');

        ErrRec.Get(1);
        Assert.AreEqual(10, ErrRec."Value", 'After OnModify error, field value must remain unchanged (rolled back)');
        Assert.AreEqual(false, ErrRec."Should Error", 'After OnModify error, record state must be rolled back');
    end;

    [Test]
    procedure OnDelete_Throws_RecordStillExists()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Should Error" := true;
        ErrRec.Insert(false);

        ErrRec.Get(1);
        asserterror ErrRec.Delete(true);

        Assert.AreEqual('OnDelete error triggered', GetLastErrorText(), 'OnDelete error text must be captured');
        Assert.IsTrue(ErrRec.Get(1), 'After OnDelete error, record must still exist (not deleted)');
    end;

    [Test]
    procedure OnValidate_Throws_FieldValueRolledBack()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Value" := 10;
        ErrRec."Should Error" := false;
        ErrRec.Insert(false);

        ErrRec.Get(1);
        ErrRec."Should Error" := true;
        asserterror ErrRec.Validate("Value", 99);

        Assert.AreEqual('OnValidate error triggered', GetLastErrorText(), 'OnValidate error text must be captured');
        Assert.AreEqual(10, ErrRec."Value", 'After OnValidate error, field value must be rolled back to original');
    end;

    [Test]
    procedure Insert_RunTriggerFalse_BypassesOnInsertError()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Should Error" := true;
        ErrRec.Insert(false);

        Assert.AreEqual(1, ErrRec.Count(), 'Insert(false) must succeed even when OnInsert would throw');
    end;

    [Test]
    procedure Delete_RunTriggerFalse_BypassesOnDeleteError()
    var
        ErrRec: Record "ALT Error Trigger";
    begin
        Initialize();

        ErrRec."Entry No." := 1;
        ErrRec."Should Error" := true;
        ErrRec.Insert(false);

        ErrRec.Get(1);
        ErrRec.Delete(false);

        Assert.AreEqual(0, ErrRec.Count(), 'Delete(false) must succeed even when OnDelete would throw');
    end;
}
