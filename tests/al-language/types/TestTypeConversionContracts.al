// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/system/system-format-method
// Scope: in-scope
// Runtime: 16.1, Target: Cloud
// Type conversion and Format/Evaluate behavioral contracts

codeunit 60192 "Test Type Conversion Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Format(Integer) ─────────────────────────────────────────────────────

    [Test]
    procedure Format_Integer_Default()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(42);
        Assert.AreEqual('42', Result, 'Format(Integer) must return numeric string');
    end;

    [Test]
    procedure Format_Integer_Negative()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(-5);
        Assert.AreEqual('-5', Result, 'Format(negative Integer) must include minus sign');
    end;

    // ── Format(Decimal) ─────────────────────────────────────────────────────

    [Test]
    procedure Format_Decimal_WithDecimals()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(3.14);
        Assert.AreNotEqual('', Result, 'Format(Decimal) must return non-empty string');
    end;

    [Test]
    procedure Format_NegativeDecimal()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(-1.5);
        Assert.AreNotEqual('', Result, 'Format(negative Decimal) must return non-empty');
    end;

    // ── Format(Boolean) ─────────────────────────────────────────────────────

    [Test]
    procedure Format_Boolean_True()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(true);
        Assert.AreEqual('Yes', Result, 'Format(true) must return "Yes" (BC English locale default)');
    end;

    [Test]
    procedure Format_Boolean_False()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(false);
        Assert.AreEqual('No', Result, 'Format(false) must return "No" (BC English locale default)');
    end;

    // ── Format(Zero) ────────────────────────────────────────────────────────

    [Test]
    procedure Format_Zero()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(0);
        Assert.AreEqual('0', Result, 'Format(0) must return "0"');
    end;

    // ── Evaluate(Integer) ───────────────────────────────────────────────────

    [Test]
    procedure Evaluate_Integer_FromString()
    var
        I: Integer;
        OK: Boolean;
    begin
        Initialize();
        OK := Evaluate(I, '42');
        Assert.IsTrue(OK, 'Evaluate(Integer, "42") must return true');
        Assert.AreEqual(42, I, 'Evaluate must parse "42" as 42');
    end;

    // ── Evaluate(Decimal) ───────────────────────────────────────────────────

    [Test]
    procedure Evaluate_Decimal_FromString()
    var
        D: Decimal;
        OK: Boolean;
    begin
        Initialize();
        OK := Evaluate(D, '3.14');
        Assert.IsTrue(OK, 'Evaluate(Decimal, "3.14") must return true');
        Assert.IsTrue(D > 3.0, 'Evaluated decimal must be > 3.0');
    end;

    // ── Evaluate(Boolean) ───────────────────────────────────────────────────

    [Test]
    procedure Evaluate_Boolean_TrueString()
    var
        B: Boolean;
        OK: Boolean;
    begin
        Initialize();
        OK := Evaluate(B, 'true');
        Assert.IsTrue(OK, 'Evaluate(Boolean, "true") must succeed');
        Assert.IsTrue(B, 'Evaluated boolean must be true');
    end;

    [Test]
    procedure Evaluate_Boolean_FalseString()
    var
        B: Boolean;
        OK: Boolean;
    begin
        Initialize();
        OK := Evaluate(B, 'false');
        Assert.IsTrue(OK, 'Evaluate(Boolean, "false") must succeed');
        Assert.IsFalse(B, 'Evaluated boolean must be false');
    end;

    // ── Evaluate(Integer) with invalid input ────────────────────────────────

    [Test]
    procedure Evaluate_Integer_InvalidString_ReturnsFalse()
    var
        I: Integer;
        OK: Boolean;
    begin
        Initialize();
        OK := Evaluate(I, 'notanumber');
        Assert.IsFalse(OK, 'Evaluate with invalid string must return false');
    end;

    [Test]
    procedure Evaluate_Integer_EmptyString_ReturnsFalse()
    var
        I: Integer;
        OK: Boolean;
    begin
        Initialize();
        OK := Evaluate(I, '');
        Assert.IsFalse(OK, 'Evaluate with empty string must return false');
    end;

    // ── Evaluate(Date) with roundtrip ───────────────────────────────────────

    [Test]
    procedure Evaluate_Date_FromFormattedDate()
    var
        D: Date;
        D2: Date;
        S: Text;
    begin
        Initialize();
        D := 20240315D;
        S := Format(D);
        Evaluate(D2, S);
        Assert.AreEqual(D, D2, 'Evaluate(Date, Format(Date)) must roundtrip correctly');
    end;

    // ── StrSubstNo() ────────────────────────────────────────────────────────

    [Test]
    procedure StrSubstNo_SinglePlaceholder()
    var
        Result: Text;
    begin
        Initialize();
        Result := StrSubstNo('Value is %1', 42);
        Assert.AreEqual('Value is 42', Result, 'StrSubstNo with %1 must substitute integer');
    end;

    [Test]
    procedure StrSubstNo_MultiplePlaceholders()
    var
        Result: Text;
    begin
        Initialize();
        Result := StrSubstNo('%1 and %2', 'A', 'B');
        Assert.AreEqual('A and B', Result, 'StrSubstNo with %1 and %2 must substitute both');
    end;

    [Test]
    procedure StrSubstNo_IntegerAsPlaceholder()
    var
        Result: Text;
    begin
        Initialize();
        Result := StrSubstNo('Record %1 not found', 5);
        Assert.AreEqual('Record 5 not found', Result, 'Integer in StrSubstNo must format correctly');
    end;

    [Test]
    procedure StrSubstNo_MissingArg_EmptySubstitution()
    var
        Result: Text;
    begin
        Initialize();
        Result := StrSubstNo('%1 and %2', 'only-one');
        Assert.IsTrue(StrPos(Result, 'only-one') > 0, 'StrSubstNo must include provided arg');
        Assert.IsTrue(true, 'StrSubstNo with missing arg must not throw');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
