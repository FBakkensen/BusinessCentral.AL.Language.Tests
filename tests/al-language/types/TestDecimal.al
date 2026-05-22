// Scope: in-scope

codeunit 60100 "Test Decimal"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Decimal arithmetic ───────────────────────────────────────────────────

    [Test]
    procedure Decimal_Arithmetic_Add()
    begin
        Initialize();
        Assert.AreEqual(3.5, 1.5 + 2.0, 'Addition: 1.5 + 2.0 must equal 3.5');
    end;

    [Test]
    procedure Decimal_Arithmetic_Subtract()
    begin
        Initialize();
        Assert.AreEqual(1.5, 3.5 - 2.0, 'Subtraction: 3.5 - 2.0 must equal 1.5');
    end;

    [Test]
    procedure Decimal_Arithmetic_Multiply()
    begin
        Initialize();
        Assert.AreEqual(6.0, 2.0 * 3.0, 'Multiplication: 2.0 * 3.0 must equal 6.0');
    end;

    [Test]
    procedure Decimal_Arithmetic_Divide()
    begin
        Initialize();
        Assert.AreEqual(2.5, 5.0 / 2.0, 'Division: 5.0 / 2.0 must equal 2.5');
    end;

    // ── Round() ──────────────────────────────────────────────────────────────

    [Test]
    procedure Decimal_Round_HalfUp()
    begin
        Initialize();
        Assert.AreEqual(3.0, Round(2.5, 1), 'Round(2.5, 1) must return 3.0 (half-up to 1 decimal place)');
    end;

    // ── Abs() ────────────────────────────────────────────────────────────────

    [Test]
    procedure Decimal_Abs_NegativeBecomesPositive()
    begin
        Initialize();
        Assert.AreEqual(5.0, Abs(-5.0), 'Abs(-5.0) must return 5.0');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
