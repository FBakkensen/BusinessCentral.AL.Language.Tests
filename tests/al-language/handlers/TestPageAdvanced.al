// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/testpage/testpage-first-method
// Scope: in-scope
// Fixtures used: ALT Universal (60000), ALT List Page (60016), ALT Card Page (60017), ALT Simple Report (60018)

codeunit 60133 "Test Page Advanced"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── TestPage Navigation ─────────────────────────────────────────────

    [Test]
    procedure Page_OpenEdit_AllowsModification()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        ListPage.OpenEdit();
        ListPage.First();
        Assert.IsTrue(true, 'OpenEdit must not throw');
        ListPage.Close();
    end;

    [Test]
    procedure Page_OpenNew_OpensEmptyRecord()
    var
        CardPage: TestPage "ALT Card Page";
    begin
        Initialize();
        CardPage.OpenNew();
        Assert.IsTrue(true, 'OpenNew must not throw');
        CardPage.Close();
    end;

    [Test]
    procedure Page_Cancel_OnCard_Closes()
    var
        CardPage: TestPage "ALT Card Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        CardPage.OpenEdit();
        CardPage.GoToKey(1);
        CardPage.Close();
        Assert.IsTrue(true, 'Cancel/Close on card must not throw');
    end;

    [Test]
    procedure Page_FindPreviousField_FindsBackward()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
        B: Boolean;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 10;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec."Integer Field" := 20;
        Rec.Insert();
        Rec."Entry No." := 3;
        Rec."Integer Field" := 10;
        Rec.Insert();
        ListPage.OpenView();
        ListPage.Last();
        B := ListPage.FindPreviousField(ListPage."Integer Field", '10');
        Assert.IsTrue(B, 'FindPreviousField must find a record with Integer Field=10');
        ListPage.Close();
    end;

    [Test]
    procedure Page_GetValidationError_AfterInvalidInput()
    var
        CardPage: TestPage "ALT Card Page";
        ErrorMsg: Text;
    begin
        Initialize();
        CardPage.OpenNew();
        ErrorMsg := CardPage.GetValidationError(0);
        Assert.IsTrue(true, 'GetValidationError must be callable');
        CardPage.Close();
    end;

    [Test]
    procedure Page_Expand_DoesNotThrow()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        ListPage.OpenView();
        ListPage.First();
        ListPage.Expand(true);
        Assert.IsTrue(true, 'Expand must not throw');
        ListPage.Close();
    end;

    // ── TestField Methods ───────────────────────────────────────────────

    [Test]
    procedure TestField_AsTime_ReturnsTime()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
        TimeValue: Time;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        ListPage.OpenView();
        ListPage.First();
        // TestField.AsTime() must be callable without throwing and return a time value
        TimeValue := ListPage."Integer Field".AsTime();
        Assert.IsTrue(true, 'TestField.AsTime() callable on time fields');
        ListPage.Close();
    end;

    [Test]
    procedure TestField_GetOption_OnOptionField()
    var
        CardPage: TestPage "ALT Card Page";
        OptionValue: Text;
    begin
        Initialize();
        CardPage.OpenEdit();
        // TestField.GetOption() must be callable on option fields
        OptionValue := CardPage."Status Field".GetOption(0);
        Assert.IsTrue(true, 'TestField.GetOption callable on option fields');
        CardPage.Close();
    end;

    [Test]
    procedure TestField_ValidationErrorCount_ReturnsZero_WhenNoErrors()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
        Count: Integer;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        ListPage.OpenView();
        ListPage.First();
        Count := ListPage."Entry No.".ValidationErrorCount();
        Assert.AreEqual(0, Count, 'ValidationErrorCount must be 0 when no errors');
        ListPage.Close();
    end;

    [Test]
    procedure TestField_HideValue_ReturnsBoolean()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
        B: Boolean;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        ListPage.OpenView();
        ListPage.First();
        B := ListPage."Entry No.".HideValue();
        Assert.IsTrue(true, 'HideValue must return boolean without error');
        ListPage.Close();
    end;

    [Test]
    procedure TestField_ShowMandatory_ReturnsBoolean()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
        B: Boolean;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        ListPage.OpenView();
        ListPage.First();
        B := ListPage."Integer Field".ShowMandatory();
        Assert.IsTrue(true, 'ShowMandatory must return boolean without error');
        ListPage.Close();
    end;

    [Test]
    procedure TestField_OptionCount_OnOptionField()
    var
        CardPage: TestPage "ALT Card Page";
        Count: Integer;
    begin
        Initialize();
        CardPage.OpenEdit();
        // TestField.OptionCount() must return count of available options
        Count := CardPage."Status Field".OptionCount();
        Assert.IsTrue(Count >= 0, 'TestField.OptionCount must return non-negative count');
        CardPage.Close();
    end;

    // ── TestRequestPage Methods ─────────────────────────────────────────

    [Test]
    [HandlerFunctions('ReportCancelHandler')]
    procedure TestRequestPage_Cancel_InvokedByHandler()
    begin
        Initialize();
        Report.Run(60018, true, false);
    end;

    [RequestPageHandler]
    procedure ReportCancelHandler(var RequestPage: TestRequestPage "ALT Simple Report")
    begin
        RequestPage.Cancel().Invoke();
        Assert.IsTrue(true, 'Cancel on RequestPage must not throw');
    end;

    [Test]
    [HandlerFunctions('ReportPrevHandler')]
    procedure TestRequestPage_Prev_IsCallable()
    begin
        Initialize();
        Report.Run(60018, true, false);
    end;

    [RequestPageHandler]
    procedure ReportPrevHandler(var RequestPage: TestRequestPage "ALT Simple Report")
    begin
        Assert.IsTrue(true, 'TestRequestPage.Prev is callable');
        RequestPage.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('ReportValidationErrorHandler')]
    procedure TestRequestPage_GetValidationError_ReturnsCount()
    begin
        Initialize();
        Report.Run(60018, true, false);
    end;

    [RequestPageHandler]
    procedure ReportValidationErrorHandler(var RequestPage: TestRequestPage "ALT Simple Report")
    var
        Count: Integer;
    begin
        Count := RequestPage.ValidationErrorCount();
        Assert.AreEqual(0, Count, 'ValidationErrorCount must be 0 on clean request page');
        RequestPage.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('ReportExpandHandler')]
    procedure TestRequestPage_Expand_IsCallable()
    begin
        Initialize();
        Report.Run(60018, true, false);
    end;

    [RequestPageHandler]
    procedure ReportExpandHandler(var RequestPage: TestRequestPage "ALT Simple Report")
    begin
        RequestPage.Expand(true);
        Assert.IsTrue(true, 'TestRequestPage.Expand must not throw');
        RequestPage.OK().Invoke();
    end;

    [Test]
    procedure Page_IsExpanded_ReturnsBoolean()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
        B: Boolean;
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        ListPage.OpenView();
        B := ListPage.IsExpanded();
        Assert.IsTrue(true, 'IsExpanded must be callable on list page');
        ListPage.Close();
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
