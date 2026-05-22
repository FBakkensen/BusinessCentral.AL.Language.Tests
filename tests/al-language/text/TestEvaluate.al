codeunit 60091 "Test Evaluate"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;
    local procedure Initialize()
    begin
        // Harmless initialization
    end;

    [Test]
    procedure Evaluate_Integer_ParsesCorrectly()
    var
        I: Integer;
    begin
        Initialize();
        Evaluate(I, '42');
        Assert.AreEqual(42, I, 'Evaluate must parse "42" as integer 42');
    end;

    [Test]
    procedure Evaluate_Decimal_ParsesCorrectly()
    var
        D: Decimal;
    begin
        Initialize();
        Evaluate(D, '3.14');
        Assert.IsTrue(D > 3.0, 'Evaluate must parse "3.14" as decimal > 3.0');
    end;

    [Test]
    procedure Evaluate_Boolean_True_ParsesCorrectly()
    var
        B: Boolean;
    begin
        Initialize();
        Evaluate(B, 'true');
        Assert.IsTrue(B, 'Evaluate must parse "true" as Boolean true');
    end;

    [Test]
    procedure Evaluate_Boolean_False_ParsesCorrectly()
    var
        B: Boolean;
    begin
        Initialize();
        Evaluate(B, 'false');
        Assert.IsFalse(B, 'Evaluate must parse "false" as Boolean false');
    end;

    [Test]
    procedure Evaluate_Date_ParsesDate()
    var
        DT: Date;
        FormattedDate: Text;
    begin
        Initialize();
        FormattedDate := Format(Today());
        Evaluate(DT, FormattedDate);
        Assert.AreEqual(Today(), DT, 'Evaluate must parse formatted date as correct Date value');
    end;

    [Test]
    procedure Evaluate_InvalidInteger_ReturnsFalse()
    var
        I: Integer;
        Result: Boolean;
    begin
        Initialize();
        Result := Evaluate(I, 'notanumber');
        Assert.IsFalse(Result, 'Evaluate must return false for invalid integer string');
    end;

    [Test]
    procedure Evaluate_EmptyString_ReturnsFalse()
    var
        I: Integer;
        Result: Boolean;
    begin
        Initialize();
        Result := Evaluate(I, '');
        Assert.IsFalse(Result, 'Evaluate must return false for empty string');
    end;
}
