codeunit 60161 "Test Arithmetic Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure IntegerPlusDecimal_ProducesDecimalResult()
    var
        I: Integer;
        D: Decimal;
        Result: Decimal;
    begin
        // Arrange
        I := 5;
        D := 3.14;

        // Act
        Result := I + D;

        // Assert
        Assert.IsTrue((Result > 8.0) and (Result < 8.2), 'Integer + Decimal must produce Decimal result ≈ 8.14');
        Assert.AreEqual(8.14, Result, 'Integer 5 + Decimal 3.14 must equal 8.14');
    end;

    [Test]
    procedure IntegerDivision_ProducesDecimal()
    var
        Result: Decimal;
    begin
        // Act
        Result := 10 / 3;

        // Assert
        Assert.IsTrue((Result > 3.3) and (Result < 3.34), '10 / 3 must produce Decimal > 3.3 (not Integer 3)');
    end;

    [Test]
    procedure Power_ZeroToZero_ReturnsOne()
    var
        Result: Decimal;
    begin
        // Act
        Result := Power(0, 0);

        // Assert
        Assert.AreEqual(1, Result, 'Power(0, 0) must return 1 by mathematical convention');
    end;

    [Test]
    procedure Power_TwoToNegativeOne_ReturnsHalf()
    var
        Result: Decimal;
    begin
        // Act
        Result := Power(2, -1);

        // Assert
        Assert.AreEqual(0.5, Result, 'Power(2, -1) must return 0.5 (negative exponent = reciprocal)');
    end;

    [Test]
    procedure Power_PositiveExponent_Correct()
    var
        Result: Decimal;
    begin
        // Act
        Result := Power(2, 10);

        // Assert
        Assert.AreEqual(1024, Result, 'Power(2, 10) must return 1024');
    end;

    [Test]
    procedure Round_HalfUp_UsesGreaterDirection()
    var
        Result: Decimal;
    begin
        // Act
        Result := Round(2.5, 1, '>');

        // Assert
        Assert.AreEqual(3.0, Result, 'Round(2.5, 1, ">") must round up to 3.0');
    end;

    [Test]
    procedure Round_HalfDown_UsesLessDirection()
    var
        Result: Decimal;
    begin
        // Act
        Result := Round(2.5, 1, '<');

        // Assert
        Assert.AreEqual(2.0, Result, 'Round(2.5, 1, "<") must round down to 2.0');
    end;

    [Test]
    procedure Round_Nearest_BankersRounding()
    var
        R1: Decimal;
        R2: Decimal;
        R3: Decimal;
    begin
        // Act
        R1 := Round(2.5, 1, '=');
        R2 := Round(2.6, 1, '=');
        R3 := Round(2.4, 1, '=');

        // Assert
        Assert.IsTrue((R1 = 2.0) or (R1 = 3.0), 'Round(2.5, 1, "=") must return either 2.0 or 3.0');
        Assert.AreEqual(3.0, R2, 'Round(2.6, 1, "=") must round to 3.0');
        Assert.AreEqual(2.0, R3, 'Round(2.4, 1, "=") must round to 2.0');
    end;

    [Test]
    procedure Abs_NegativeInteger_ReturnsPositive()
    var
        Result: Integer;
    begin
        // Act
        Result := Abs(-2147483647);

        // Assert
        Assert.AreEqual(2147483647, Result, 'Abs(-MaxInt) must return MaxInt');
    end;

    [Test]
    procedure Abs_NegativeDecimal_ReturnsPositive()
    var
        Result: Decimal;
    begin
        // Act
        Result := Abs(-123.45);

        // Assert
        Assert.AreEqual(123.45, Result, 'Abs(-123.45) must return 123.45');
    end;

    [Test]
    procedure Modulo_ByZero_Throws()
    var
        I: Integer;
        Zero: Integer;
    begin
        // Arrange
        Zero := 0;

        // Act & Assert
        asserterror I := 5 mod Zero;
        Assert.AreNotEqual('', GetLastErrorText(), '5 mod 0 must throw a runtime error');
    end;

    [Test]
    procedure IncStr_NinetyNine_ExpandsWidth()
    var
        Result: Code[100];
    begin
        // Act
        Result := IncStr('99');

        // Assert
        Assert.AreEqual('100', Result, 'IncStr("99") must expand width: 99 → 100');
    end;

    [Test]
    procedure IncStr_AlphaNinetyNine_ExpandsWidth()
    var
        Result: Code[100];
    begin
        // Act
        Result := IncStr('A99');

        // Assert
        Assert.AreEqual('A100', Result, 'IncStr("A99") must expand width: A99 → A100');
    end;

    [Test]
    procedure IncStr_LeadingZeros_Preserved()
    var
        Result: Code[100];
    begin
        // Act
        Result := IncStr('009');

        // Assert
        Assert.AreEqual('010', Result, 'IncStr("009") must preserve leading zero width: 009 → 010');
    end;

    [Test]
    procedure Integer_Div_IsIntegerDivision()
    var
        I: Integer;
    begin
        // Act
        I := 10 div 3;

        // Assert
        Assert.AreEqual(3, I, '10 div 3 must return Integer 3 (integer division truncates)');
    end;

    trigger OnRun()
    begin
        Cleanup.Initialize();
    end;


}
