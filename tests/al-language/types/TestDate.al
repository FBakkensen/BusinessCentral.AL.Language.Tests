// Scope: in-scope

codeunit 60099 "Test Date"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Today() ──────────────────────────────────────────────────────────────

    [Test]
    procedure Date_Today_ReturnsNonEmpty()
    begin
        Initialize();
        Assert.AreNotEqual(0D, Today(), 'Today() must return a non-zero date');
    end;

    // ── CalcDate() ───────────────────────────────────────────────────────────

    [Test]
    procedure Date_CalcDate_AddsDays()
    var
        D: Date;
    begin
        Initialize();
        D := CalcDate('<+1D>', 20240101D);
        Assert.AreEqual(20240102D, D, 'CalcDate(''<+1D>'', 20240101D) must return 20240102D');
    end;

    [Test]
    procedure Date_CalcDate_SubtractsDays()
    var
        D: Date;
    begin
        Initialize();
        D := CalcDate('<-1D>', 20240102D);
        Assert.AreEqual(20240101D, D, 'CalcDate(''<-1D>'', 20240102D) must return 20240101D');
    end;

    // ── Date2DMY() ───────────────────────────────────────────────────────────

    [Test]
    procedure Date_Date2DMY_ReturnsDay()
    begin
        Initialize();
        Assert.AreEqual(15, Date2DMY(20240115D, 1), 'Date2DMY(20240115D, 1) must return 15 (day component)');
    end;

    [Test]
    procedure Date_Date2DMY_ReturnsMonth()
    begin
        Initialize();
        Assert.AreEqual(1, Date2DMY(20240115D, 2), 'Date2DMY(20240115D, 2) must return 1 (month component)');
    end;

    [Test]
    procedure Date_Date2DMY_ReturnsYear()
    begin
        Initialize();
        Assert.AreEqual(2024, Date2DMY(20240115D, 3), 'Date2DMY(20240115D, 3) must return 2024 (year component)');
    end;

    // ── DMY2Date() ───────────────────────────────────────────────────────────

    [Test]
    procedure Date_DMY2Date_ConstructsDate()
    begin
        Initialize();
        Assert.AreEqual(20240115D, DMY2Date(15, 1, 2024), 'DMY2Date(15, 1, 2024) must return 20240115D');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
