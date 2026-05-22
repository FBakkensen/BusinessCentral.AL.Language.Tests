// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/dateformula/dateformula-data-type
// Scope: in-scope
// Fixtures used: ALT Universal (60000)

codeunit 60180 "Test DateFormula Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── DateFormula.Evaluate() ──────────────────────────────────────────────────

    [Test]
    procedure DateFormula_Evaluate_PlusOneDay_Parseable()
    var
        DF: DateFormula;
    begin
        Initialize();
        Evaluate(DF, '<1D>');
        Assert.AreNotEqual('', Format(DF), 'Evaluate("<1D>") must parse DateFormula successfully');
    end;

    [Test]
    procedure DateFormula_Evaluate_PlusOneMonth_Parseable()
    var
        DF: DateFormula;
    begin
        Initialize();
        Evaluate(DF, '<1M>');
        Assert.AreNotEqual('', Format(DF), 'Evaluate("<1M>") must parse DateFormula');
    end;

    // ── DateFormula with CalcDate() ─────────────────────────────────────────────

    [Test]
    procedure DateFormula_CalcDate_PlusOneDay()
    var
        DF: DateFormula;
        D: Date;
    begin
        Initialize();
        Evaluate(DF, '<1D>');
        D := CalcDate(DF, 20240101D);
        Assert.AreEqual(20240102D, D, 'CalcDate with DateFormula <1D> from Jan 1 must give Jan 2');
    end;

    [Test]
    procedure DateFormula_CalcDate_PlusOneMonth()
    var
        DF: DateFormula;
        D: Date;
    begin
        Initialize();
        Evaluate(DF, '<1M>');
        D := CalcDate(DF, 20240101D);
        Assert.AreEqual(20240201D, D, 'CalcDate with DateFormula <1M> from Jan 1 must give Feb 1');
    end;

    [Test]
    procedure DateFormula_CalcDate_MinusOneDay()
    var
        DF: DateFormula;
        D: Date;
    begin
        Initialize();
        Evaluate(DF, '<-1D>');
        D := CalcDate(DF, 20240102D);
        Assert.AreEqual(20240101D, D, 'CalcDate with DateFormula <-1D> from Jan 2 must give Jan 1');
    end;

    // ── DateFormula.Format() ────────────────────────────────────────────────────

    [Test]
    procedure DateFormula_Format_ReturnsFormula()
    var
        DF: DateFormula;
        S: Text;
    begin
        Initialize();
        Evaluate(DF, '<1D>');
        S := Format(DF);
        Assert.IsTrue((StrPos(S, '1D') > 0) or (StrLen(S) > 0), 'Format(DateFormula) must return non-empty string');
    end;

    // ── DateFormula default value ───────────────────────────────────────────────

    [Test]
    procedure DateFormula_Default_IsEmpty()
    var
        DF: DateFormula;
    begin
        Initialize();
        Assert.AreEqual('', Format(DF), 'Default DateFormula must format to empty string');
    end;

    // ── DateFormula with current month ──────────────────────────────────────────

    [Test]
    procedure DateFormula_Evaluate_CurrentMonth()
    var
        DF: DateFormula;
        D: Date;
    begin
        Initialize();
        Evaluate(DF, '<CM>');
        D := CalcDate(DF, Today());
        Assert.AreEqual(Date2DMY(Today(), 2), Date2DMY(D, 2), 'DateFormula <CM> must stay in current month');
    end;

    // ── DateFormula determinism ────────────────────────────────────────────────

    [Test]
    procedure DateFormula_Validate_DoesNotThrow()
    var
        DF: DateFormula;
        D1: Date;
        D2: Date;
    begin
        Initialize();
        Evaluate(DF, '<1Y>');
        D1 := CalcDate(DF, 20240101D);
        D2 := CalcDate(DF, 20240101D);
        Assert.AreEqual(D1, D2, 'CalcDate with same DateFormula must be deterministic');
    end;

    // ── DateFormula equality ────────────────────────────────────────────────────

    [Test]
    procedure DateFormula_Comparison_Equal()
    var
        DF1: DateFormula;
        DF2: DateFormula;
    begin
        Initialize();
        Evaluate(DF1, '<1D>');
        Evaluate(DF2, '<1D>');
        Assert.AreEqual(Format(DF1), Format(DF2), 'Two DateFormulas from same expression must format identically');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
