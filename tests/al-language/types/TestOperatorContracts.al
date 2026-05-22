codeunit 60188 "Test Operator Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    trigger OnRun()
    begin
        Cleanup.Initialize();
    end;

    [Test]
    procedure UnaryMinus_Integer()
    var
        I: Integer;
    begin
        I := 5;
        Assert.AreEqual(-5, -I, 'Unary minus on Integer must negate');
    end;

    [Test]
    procedure UnaryMinus_Decimal()
    var
        D: Decimal;
    begin
        D := 3.14;
        Assert.AreEqual(-3.14, -D, 'Unary minus on Decimal must negate');
    end;

    [Test]
    procedure UnaryMinus_Applied_Twice()
    var
        I: Integer;
    begin
        I := 7;
        Assert.AreEqual(7, -(-I), 'Double negation must return original value');
    end;

    [Test]
    procedure Not_Boolean_True()
    begin
        Assert.IsFalse(not true, 'not true must be false');
    end;

    [Test]
    procedure Not_Boolean_False()
    begin
        Assert.IsTrue(not false, 'not false must be true');
    end;

    [Test]
    procedure Not_Not_Boolean()
    begin
        Assert.IsTrue(not not true, 'not not true must be true');
    end;

    [Test]
    procedure Integer_Mod_Positive()
    begin
        Assert.AreEqual(1, 7 mod 3, '7 mod 3 must equal 1');
    end;

    [Test]
    procedure Integer_Mod_Zero_Result()
    begin
        Assert.AreEqual(0, 6 mod 3, '6 mod 3 must equal 0 (no remainder)');
    end;

    [Test]
    procedure Integer_Mod_Negative_Dividend()
    var
        Result: Integer;
    begin
        Result := -7 mod 3;
        Assert.AreEqual(-1, Result, '-7 mod 3 must equal -1 in BC (sign follows dividend)');
    end;

    [Test]
    procedure Integer_Div_Truncates()
    var
        Result1: Integer;
        Result2: Integer;
    begin
        Result1 := 10 div 3;
        Result2 := -10 div 3;
        Assert.AreEqual(3, Result1, '10 div 3 must truncate to 3 (not round)');
        Assert.AreEqual(-3, Result2, '-10 div 3 must truncate toward zero: -3');
    end;

    [Test]
    procedure Integer_Div_Negative()
    var
        Result: Integer;
    begin
        Result := 10 div -3;
        Assert.AreEqual(-3, Result, '10 div -3 must equal -3');
    end;

    [Test]
    procedure String_Concatenation()
    var
        Result: Text;
    begin
        Result := 'Hello' + 'World';
        Assert.AreEqual('HelloWorld', Result, 'String + string must concatenate');
    end;

    [Test]
    procedure String_PlusInteger_WithFormat()
    var
        Result: Text;
    begin
        Result := 'Value: ' + Format(42);
        Assert.AreEqual('Value: 42', Result, 'String + Format(Integer) must concatenate');
    end;

    [Test]
    procedure Comparison_Integer_AllOperators()
    begin
        Assert.IsTrue(3 < 5, '3 < 5 must be true');
        Assert.IsTrue(5 > 3, '5 > 3 must be true');
        Assert.IsTrue(3 <= 3, '3 <= 3 must be true');
        Assert.IsTrue(3 >= 3, '3 >= 3 must be true');
        Assert.IsTrue(3 = 3, '3 = 3 must be true');
        Assert.IsTrue(3 <> 4, '3 <> 4 must be true');
    end;

    [Test]
    procedure Boolean_AndOr_LogicalOperations()
    begin
        Assert.IsTrue(true and true, 'true AND true = true');
        Assert.IsFalse(true and false, 'true AND false = false');
        Assert.IsTrue(true or false, 'true OR false = true');
        Assert.IsFalse(false or false, 'false OR false = false');
    end;

    [Test]
    procedure XOR_Boolean_Equivalence()
    var
        A: Boolean;
        B: Boolean;
        XorResult: Boolean;
    begin
        A := true;
        B := false;
        XorResult := (A or B) and not (A and B);
        Assert.IsTrue(XorResult, 'true XOR false must be true via (A or B) and not (A and B)');
    end;
}
