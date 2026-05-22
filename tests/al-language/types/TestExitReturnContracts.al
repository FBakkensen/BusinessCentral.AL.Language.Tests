codeunit 60185 "Test Exit Return Contracts"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    trigger OnRun()
    begin
        Cleanup.Initialize();
    end;

    [Test]
    procedure Exit_WithValue_ReturnsValue()
    var
        Result: Integer;
    begin
        // Arrange & Act
        Result := ReturnFive();

        // Assert
        Assert.AreEqual(5, Result, 'Procedure with exit(5) must return 5');
    end;

    [Test]
    procedure Exit_WithExpression_ReturnsCalculated()
    var
        Result: Integer;
    begin
        // Arrange & Act
        Result := ReturnDouble(7);

        // Assert
        Assert.AreEqual(14, Result, 'exit(2*X) must return 14 when X=7');
    end;

    [Test]
    procedure Exit_WithStringConcat_ReturnsText()
    var
        Result: Text;
    begin
        // Arrange & Act
        Result := ReturnGreeting('World');

        // Assert
        Assert.AreEqual('Hello World', Result, 'exit("Hello " + name) must return "Hello World"');
    end;

    [Test]
    procedure Exit_EarlyExit_SkipsRemainingCode()
    var
        Result: Integer;
    begin
        // Arrange & Act
        Result := ConditionalReturn(true);

        // Assert
        Assert.AreEqual(1, Result, 'Early exit(1) when condition=true must return 1 not 2');
    end;

    [Test]
    procedure Exit_FalseCondition_ContinuesToNormalReturn()
    var
        Result: Integer;
    begin
        // Arrange & Act
        Result := ConditionalReturn(false);

        // Assert
        Assert.AreEqual(2, Result, 'Normal flow when condition=false must reach exit(2)');
    end;

    [Test]
    procedure Exit_Recursive_SumsCorrectly()
    var
        Result: Integer;
    begin
        // Arrange & Act
        Result := SumUpTo(5);

        // Assert
        Assert.AreEqual(15, Result, 'Recursive exit(N + SumUpTo(N-1)) with N=5 must return 15 (5+4+3+2+1)');
    end;

    [Test]
    procedure Exit_WithBooleanExpression()
    begin
        // Arrange & Act & Assert
        Assert.IsTrue(IsPositive(5), 'exit(X > 0) must return true for X=5');
        Assert.IsFalse(IsPositive(-1), 'exit(X > 0) must return false for X=-1');
    end;

    [Test]
    procedure Exit_FromNestedBlock()
    var
        Result: Integer;
    begin
        // Arrange & Act
        Result := ExitFromLoop(3);

        // Assert
        Assert.AreEqual(3, Result, 'exit() from inside a loop must return the accumulated value');
    end;

    [Test]
    procedure Exit_WithDecimalCalculation()
    var
        Result: Decimal;
    begin
        // Arrange & Act
        Result := CalcAverage(10, 20);

        // Assert
        Assert.AreEqual(15, Result, 'exit((A+B)/2) must return 15 for A=10, B=20');
    end;

    [Test]
    procedure Exit_WithProcedureCall_InExpr()
    var
        Result: Integer;
    begin
        // Arrange & Act
        Result := NestCalls();

        // Assert
        Assert.AreEqual(100, Result, 'exit(Square(10)) must return 100');
    end;

    local procedure ReturnFive(): Integer
    begin
        exit(5);
    end;

    local procedure ReturnDouble(X: Integer): Integer
    begin
        exit(2 * X);
    end;

    local procedure ReturnGreeting(Name: Text): Text
    begin
        exit('Hello ' + Name);
    end;

    local procedure ConditionalReturn(Condition: Boolean): Integer
    begin
        if Condition then exit(1);
        exit(2);
    end;

    local procedure SumUpTo(N: Integer): Integer
    begin
        if N <= 0 then exit(0);
        exit(N + SumUpTo(N - 1));
    end;

    local procedure IsPositive(X: Integer): Boolean
    begin
        exit(X > 0);
    end;

    local procedure ExitFromLoop(Target: Integer): Integer
    var
        Sum: Integer;
        i: Integer;
    begin
        for i := 1 to 10 do begin
            Sum += 1;
            if Sum = Target then exit(Sum);
        end;
        exit(Sum);
    end;

    local procedure CalcAverage(A: Decimal; B: Decimal): Decimal
    begin
        exit((A + B) / 2);
    end;

    local procedure Square(N: Integer): Integer
    begin
        exit(N * N);
    end;

    local procedure NestCalls(): Integer
    begin
        exit(Square(10));
    end;
}
