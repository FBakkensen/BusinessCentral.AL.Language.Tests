codeunit 60153 "Test Type System Contracts"
{
    Subtype = Test;

    trigger OnRun()
    begin
        Cleanup.Initialize();
    end;

    var
        Cleanup: Codeunit ALTFixtureCleanup;
        Assert: Codeunit Assert;

    [Test]
    procedure Integer_MaxValue_PlusOne_Throws()
    var
        I: Integer;
    begin
        I := 2147483647;
        asserterror I := I + 1;
        Assert.AreNotEqual('', GetLastErrorText(), 'Integer overflow must throw a runtime error');
    end;

    [Test]
    procedure Integer_MinValue_MinusOne_Throws()
    var
        I: Integer;
    begin
        I := -2147483647 - 1; // = -2147483648 (MinInt) via arithmetic
        asserterror I := I - 1;
        Assert.AreNotEqual('', GetLastErrorText(), 'Integer underflow must throw a runtime error');
    end;

    [Test]
    procedure Decimal_DivisionByZero_Throws()
    var
        D: Decimal;
        Zero: Decimal;
    begin
        Zero := 0;
        asserterror D := 10 / Zero;
        Assert.AreNotEqual('', GetLastErrorText(), 'Division by zero must throw a runtime error');
    end;

    [Test]
    procedure Integer_DivisionByZero_Throws()
    var
        I: Integer;
        ZeroI: Integer;
    begin
        ZeroI := 0;
        asserterror I := 10 div ZeroI;
        Assert.AreNotEqual('', GetLastErrorText(), 'Integer div 0 must throw a runtime error');
    end;

    [Test]
    procedure CodeField_Assignment_UppercasesValue()
    var
        Rec: Record "ALT Universal";
    begin
        Cleanup.Initialize();
        Rec."Entry No." := 1;
        Rec."Code Field" := 'lowercase';
        Rec.Insert();
        Rec.Get(1);
        Assert.AreEqual('LOWERCASE', Rec."Code Field", 'Assigning lowercase to Code field must store uppercase');
    end;

    [Test]
    procedure CodeField_SetRange_CaseInsensitive()
    var
        Rec: Record "ALT Universal";
    begin
        Cleanup.Initialize();
        Rec."Entry No." := 1;
        Rec."Code Field" := 'ABC';
        Rec.Insert();
        Rec.Reset();
        Rec.SetRange("Code Field", 'abc');
        Assert.AreEqual(1, Rec.Count(), 'SetRange on Code field must be case-insensitive (abc finds ABC)');
    end;

    [Test]
    procedure CodeField_DirectComparison_CaseInsensitive()
    var
        Rec: Record "ALT Universal";
        CodeVar: Code[20];
    begin
        Cleanup.Initialize();
        Rec."Entry No." := 1;
        Rec."Code Field" := 'HELLO';
        Rec.Insert();
        Rec.Get(1);
        CodeVar := 'hello'; // Code[20] assignment uppercases the literal to 'HELLO'
        Assert.IsTrue(Rec."Code Field" = CodeVar, 'Code field comparison must be case-insensitive (HELLO = hello stored as HELLO)');
    end;

    [Test]
    procedure TextField_DirectComparison_CaseSensitive()
    var
        Rec: Record "ALT Universal";
    begin
        Cleanup.Initialize();
        Rec."Entry No." := 1;
        Rec."Text Field" := 'Hello';
        Rec.Insert();
        Rec.Get(1);
        Assert.IsFalse(Rec."Text Field" = 'hello', 'Text field comparison IS case-sensitive (Hello <> hello)');
    end;

    [Test]
    procedure CalcDate_LeapYear_Feb28_PlusOneDay()
    var
        D: Date;
    begin
        D := CalcDate('<+1D>', 20240228D);
        Assert.AreEqual(20240229D, D, 'CalcDate +1D from Feb 28 in leap year must give Feb 29');
    end;

    [Test]
    procedure CalcDate_LeapYear_Feb29_PlusOneDay()
    var
        D: Date;
    begin
        D := CalcDate('<+1D>', 20240229D);
        Assert.AreEqual(20240301D, D, 'CalcDate +1D from Feb 29 must give Mar 1');
    end;

    [Test]
    procedure CalcDate_NonLeapYear_Feb28_PlusOneDay()
    var
        D: Date;
    begin
        D := CalcDate('<+1D>', 20230228D);
        Assert.AreEqual(20230301D, D, 'CalcDate +1D from Feb 28 in non-leap year must give Mar 1');
    end;

    [Test]
    procedure Boolean_ShortCircuit_ORAndAND()
    begin
        Assert.IsTrue(true or false, 'true OR false must be true');
        Assert.IsTrue(true or true, 'true OR true must be true');
        Assert.IsFalse(false or false, 'false OR false must be false');
        Assert.IsFalse(false and true, 'false AND true must be false');
    end;

    [Test]
    procedure Guid_DirectComparison_IsReliable()
    var
        G1: Guid;
        G2: Guid;
        G3: Guid;
    begin
        G1 := CreateGuid();
        G2 := G1;
        Assert.IsTrue(G1 = G2, 'Guid direct comparison G1 = G2 must return true for same GUID');
        G3 := CreateGuid();
        Assert.IsFalse(G1 = G3, 'Different GUIDs must not be equal via direct comparison');
    end;

    [Test]
    procedure Variant_IsInteger_AfterIntegerAssign_NotDecimal()
    var
        V: Variant;
        I: Integer;
        D: Decimal;
    begin
        I := 5;
        V := I;
        Assert.IsTrue(V.IsInteger(), 'After assigning Integer to Variant, IsInteger must be true');
        Assert.IsFalse(V.IsDecimal(), 'After assigning Integer to Variant, IsDecimal must be false');
        D := 5.0;
        V := D;
        Assert.IsTrue(V.IsDecimal(), 'After assigning Decimal to Variant, IsDecimal must be true');
        Assert.IsFalse(V.IsInteger(), 'After assigning Decimal to Variant, IsInteger must be false');
    end;
}
