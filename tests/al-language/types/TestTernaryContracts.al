codeunit 60193 "Test Ternary Contracts"
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
    procedure Ternary_TrueCondition_ReturnsFirstBranch()
    var
        Result: Text;
    begin
        Result := (5 > 3) ? 'big' : 'small';
        Assert.AreEqual('big', Result, 'Ternary with true condition must return first branch');
    end;

    [Test]
    procedure Ternary_FalseCondition_ReturnsSecondBranch()
    var
        Result: Text;
    begin
        Result := (3 > 5) ? 'big' : 'small';
        Assert.AreEqual('small', Result, 'Ternary with false condition must return second branch');
    end;

    [Test]
    procedure Ternary_Integer_TrueCondition()
    var
        Result: Integer;
    begin
        Result := (10 > 5) ? 100 : 200;
        Assert.AreEqual(100, Result, 'Ternary with integer values: true → 100');
    end;

    [Test]
    procedure Ternary_Integer_FalseCondition()
    var
        Result: Integer;
    begin
        Result := (5 > 10) ? 100 : 200;
        Assert.AreEqual(200, Result, 'Ternary with integer values: false → 200');
    end;

    [Test]
    procedure Ternary_InExitExpression()
    var
        Result: Text;
    begin
        Result := ClassifyNumber(7);
        Assert.AreEqual('big', Result, 'exit(n > 3 ? "big" : "small") must return "big" for n=7');
    end;

    [Test]
    procedure Ternary_InExitExpression_Opposite()
    var
        Result: Text;
    begin
        Result := ClassifyNumber(2);
        Assert.AreEqual('small', Result, 'exit(n > 3 ? "big" : "small") must return "small" for n=2');
    end;

    [Test]
    procedure Ternary_BothBranches_Differ()
    begin
        Assert.AreNotEqual(ClassifyNumber(10), ClassifyNumber(0), 'Ternary must produce different values for different branches');
    end;

    [Test]
    procedure Ternary_NestedTernary()
    var
        Result: Text;
    begin
        Result := BucketNumber(5);
        Assert.AreEqual('low', Result, 'Nested ternary: 5 < 10 → "low"');
    end;

    [Test]
    procedure Ternary_NestedTernary_Middle()
    var
        Result: Text;
    begin
        Result := BucketNumber(50);
        Assert.AreEqual('mid', Result, 'Nested ternary: 50 not < 10 but < 100 → "mid"');
    end;

    [Test]
    procedure Ternary_NestedTernary_High()
    var
        Result: Text;
    begin
        Result := BucketNumber(500);
        Assert.AreEqual('high', Result, 'Nested ternary: 500 not < 100 → "high"');
    end;

    [Test]
    procedure Ternary_Max_ReturnsLarger()
    var
        Result: Integer;
    begin
        Result := MaxOfTwo(7, 4);
        Assert.AreEqual(7, Result, 'a >= b ? a : b must return larger value');
    end;

    [Test]
    procedure Ternary_FlipBoolean()
    var
        Result: Boolean;
    begin
        Result := FlipBool(true);
        Assert.IsFalse(Result, 'Ternary flip: true ? false : true must return false');
    end;

    local procedure ClassifyNumber(N: Integer): Text
    begin
        exit(N > 3 ? 'big' : 'small');
    end;

    local procedure BucketNumber(N: Integer): Text
    begin
        exit(N < 10 ? 'low' : N < 100 ? 'mid' : 'high');
    end;

    local procedure MaxOfTwo(A: Integer; B: Integer): Integer
    begin
        exit(A >= B ? A : B);
    end;

    local procedure FlipBool(B: Boolean): Boolean
    begin
        exit(B ? false : true);
    end;
}
