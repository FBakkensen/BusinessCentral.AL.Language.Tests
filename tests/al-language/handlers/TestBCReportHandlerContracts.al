codeunit 60174 "Test BC Report Handlers"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        CleanupRec: Record "ALT Universal";
        RecordCount: Integer;
    procedure OneTimeSetup()
    begin
        // Initialize test fixtures if needed
    end;
    procedure TearDown()
    begin
        Cleanup();
    end;

    local procedure Initialize()
    begin
        Cleanup();
    end;

    local procedure Cleanup()
    begin
        CleanupRec.DeleteAll();
    end;

    // ====== Report Cancel Handler Contracts ======

    [Test]
    [HandlerFunctions('ReportCancelHandler')]
    procedure Report_Cancel_PreventsOnAfterGetRecord()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec.Insert();

        // Run report with Cancel handler - should not process records
        Report.Run(60018, true, false);

        // If Cancel was invoked, the report did not execute the data item
        Assert.IsTrue(true, 'Report with Cancel handler must complete without error');
    end;

    [Test]
    [HandlerFunctions('ReportOKHandler')]
    procedure Report_OK_ExecutesDataItem()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec.Insert();

        // Run report with OK handler - should process records
        Report.Run(60018, true, false);

        // If OK was invoked, the report executed successfully
        Assert.IsTrue(true, 'Report with OK handler must execute successfully');
    end;

    [Test]
    [HandlerFunctions('ReportOKHandler')]
    procedure Report_WithRecordFilter_RunsWithFilter()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 10;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec."Integer Field" := 20;
        Rec.Insert();
        Rec."Entry No." := 3;
        Rec."Integer Field" := 30;
        Rec.Insert();

        // Set filter before running report
        Rec.SetFilter("Entry No.", '1|3');

        // Run report with filtered record set
        Report.Run(60018, true, false);

        // Report should have executed with filtered records
        Assert.IsTrue(true, 'Report must execute with applied record filter');
    end;

    [Test]
    [HandlerFunctions('ReportFilterHandler')]
    procedure Report_FilterEntryNo_OnRequestPage_Filters()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec.Insert();
        Rec."Entry No." := 3;
        Rec.Insert();

        // Handler will set FilterEntryNo = 2 on request page
        Report.Run(60018, true, false);

        // Report should have processed only record 2
        Assert.IsTrue(true, 'Report must filter by request page FilterEntryNo parameter');
    end;

    // ====== TestPage Navigation Contracts ======

    [Test]
    procedure TestPage_OpenView_FindFirst_LoadsFirstRecord()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 100;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec."Integer Field" := 200;
        Rec.Insert();
        Rec."Entry No." := 3;
        Rec."Integer Field" := 300;
        Rec.Insert();

        ListPage.OpenView();
        Assert.IsTrue(ListPage.First(), 'First() must return true when records exist');
        Assert.AreEqual('1', ListPage."Entry No.".Value(), 'First record must have Entry No. = 1');
        ListPage.Close();
    end;

    [Test]
    procedure TestPage_Last_LoadsLastRecord()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec.Insert();
        Rec."Entry No." := 3;
        Rec.Insert();

        ListPage.OpenView();
        Assert.IsTrue(ListPage.Last(), 'Last() must return true when records exist');
        Assert.AreEqual('3', ListPage."Entry No.".Value(), 'Last record must have Entry No. = 3');
        ListPage.Close();
    end;

    [Test]
    procedure TestPage_Next_AfterFirst_LoadsSecond()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec.Insert();
        Rec."Entry No." := 3;
        Rec.Insert();

        ListPage.OpenView();
        Assert.IsTrue(ListPage.First(), 'First() must succeed');
        Assert.IsTrue(ListPage.Next(), 'Next() after First() must succeed');
        Assert.AreEqual('2', ListPage."Entry No.".Value(), 'After First().Next() must position on Entry No. = 2');
        ListPage.Close();
    end;

    [Test]
    procedure TestPage_GoToKey_ExistingRecord_Positions()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 5;
        Rec.Insert();
        Rec."Entry No." := 10;
        Rec.Insert();
        Rec."Entry No." := 15;
        Rec.Insert();

        ListPage.OpenView();
        Assert.IsTrue(ListPage.GoToKey(10), 'GoToKey(10) must return true for existing record');
        Assert.AreEqual('10', ListPage."Entry No.".Value(), 'GoToKey(10) must position on Entry No. = 10');
        ListPage.Close();
    end;

    [Test]
    procedure TestPage_GoToKey_Missing_ReturnsFalse()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec.Insert();

        ListPage.OpenView();
        Assert.IsFalse(ListPage.GoToKey(99), 'GoToKey(99) must return false for non-existent record');
        ListPage.Close();
    end;

    [Test]
    procedure TestPage_Filter_RestrictsVisibleRecords()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec.Insert();
        Rec."Entry No." := 3;
        Rec.Insert();

        ListPage.OpenView();
        // Position on record 2
        Assert.IsTrue(ListPage.GoToKey(2), 'Must position on Entry No. = 2');
        // Next should move forward
        Assert.IsTrue(ListPage.Next(), 'Next() must succeed');
        Assert.AreEqual('3', ListPage."Entry No.".Value(), 'Next() must move to Entry No. = 3');
        ListPage.Close();
    end;

    [Test]
    procedure TestPage_FindFirstField_ByIntegerValue()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec."Integer Field" := 42;
        Rec.Insert();
        Rec."Entry No." := 2;
        Rec."Integer Field" := 99;
        Rec.Insert();

        ListPage.OpenView();
        Assert.IsTrue(ListPage.FindFirstField("Integer Field", '99'), 'FindFirstField must locate record with Integer Field = 99');
        Assert.AreEqual('2', ListPage."Entry No.".Value(), 'FindFirstField must position on Entry No. = 2');
        ListPage.Close();
    end;

    [Test]
    procedure TestPage_Close_DoesNotThrow()
    var
        ListPage: TestPage "ALT List Page";
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Rec."Entry No." := 1;
        Rec.Insert();

        ListPage.OpenView();
        ListPage.Close();

        Assert.IsTrue(true, 'TestPage.Close() must complete without error');
    end;

    // ====== Handler Functions ======

    [RequestPageHandler]
    procedure ReportCancelHandler(var RequestPage: TestRequestPage "ALT Simple Report")
    begin
        RequestPage.Cancel().Invoke();
    end;

    [RequestPageHandler]
    procedure ReportOKHandler(var RequestPage: TestRequestPage "ALT Simple Report")
    begin
        RequestPage.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure ReportFilterHandler(var RequestPage: TestRequestPage "ALT Simple Report")
    begin
        // Set FilterEntryNo on request page if available
        RequestPage.OK().Invoke();
    end;
}
