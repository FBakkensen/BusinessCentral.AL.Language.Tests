codeunit 60189 "Test IfElse Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure If_TrueCondition_ExecutesThenBranch()
    var
        Result: Text;
    begin
        Cleanup.Initialize();

        Result := 'unchanged';
        if true then
            Result := 'then';

        Assert.AreEqual('then', Result, 'if true must execute then branch');
    end;

    [Test]
    procedure If_FalseCondition_SkipsThenBranch()
    var
        Result: Text;
    begin
        Cleanup.Initialize();

        Result := 'original';
        if false then
            Result := 'changed';

        Assert.AreEqual('original', Result, 'if false must NOT execute then branch');
    end;

    [Test]
    procedure If_FalseCondition_ExecutesElse()
    var
        Result: Text;
    begin
        Cleanup.Initialize();

        if false then
            Result := 'then'
        else
            Result := 'else';

        Assert.AreEqual('else', Result, 'if false must execute else branch');
    end;

    [Test]
    procedure If_TrueCondition_SkipsElse()
    var
        Result: Text;
    begin
        Cleanup.Initialize();

        Result := 'initial';
        if true then
            Result := 'then'
        else
            Result := 'else';

        Assert.AreEqual('then', Result, 'if true must execute then and skip else');
    end;

    [Test]
    procedure If_NestedIfElse_InnerThenOuter()
    var
        I: Integer;
        Result: Text;
    begin
        Cleanup.Initialize();

        I := 5;
        if I > 0 then
            if I > 10 then
                Result := 'large'
            else
                Result := 'small'
        else
            Result := 'negative';

        Assert.AreEqual('small', Result, 'Nested if: 5 > 0 and 5 <= 10 must give "small"');
    end;

    [Test]
    procedure If_DanglingElse_BindsToNearest()
    var
        I: Integer;
        Result: Text;
    begin
        Cleanup.Initialize();

        I := -1;
        if I > 0 then
            if I > 10 then
                Result := 'large'
            else
                Result := 'small-positive';

        Assert.AreEqual('', Result, 'Dangling else binds to nearest if; outer false means nothing runs');
    end;

    [Test]
    procedure If_CompoundCondition_And()
    var
        A: Boolean;
        B: Boolean;
        Result: Integer;
    begin
        Cleanup.Initialize();

        A := true;
        B := true;
        if A and B then
            Result := 1
        else
            Result := 0;

        Assert.AreEqual(1, Result, 'if (true AND true) must execute then branch');
    end;

    [Test]
    procedure If_CompoundCondition_Or()
    var
        A: Boolean;
        B: Boolean;
        Result: Integer;
    begin
        Cleanup.Initialize();

        A := false;
        B := true;
        if A or B then
            Result := 1
        else
            Result := 0;

        Assert.AreEqual(1, Result, 'if (false OR true) must execute then branch');
    end;

    [Test]
    procedure If_WithBeginEnd_MultiplStatements()
    var
        I: Integer;
        X: Integer;
        Y: Integer;
    begin
        Cleanup.Initialize();

        I := 5;
        if I > 0 then begin
            X := 10;
            Y := 20;
        end;

        Assert.AreEqual(10, X, 'begin..end in if must execute all statements');
        Assert.AreEqual(20, Y, 'Second statement in begin..end must also execute');
    end;

    [Test]
    procedure If_ElseIf_Chain()
    var
        I: Integer;
        Result: Text;
    begin
        Cleanup.Initialize();

        I := 3;
        if I = 1 then
            Result := 'one'
        else if I = 2 then
            Result := 'two'
        else if I = 3 then
            Result := 'three'
        else
            Result := 'other';

        Assert.AreEqual('three', Result, 'else-if chain must match correct branch (I=3)');
    end;

    [Test]
    procedure If_ElseIf_FallsToElse()
    var
        I: Integer;
        Result: Text;
    begin
        Cleanup.Initialize();

        I := 99;
        if I = 1 then
            Result := 'one'
        else if I = 2 then
            Result := 'two'
        else
            Result := 'other';

        Assert.AreEqual('other', Result, 'else-if chain must fall to final else when no match');
    end;

    [Test]
    procedure If_Condition_IsExpression()
    var
        I: Integer;
        Result: Boolean;
    begin
        Cleanup.Initialize();

        I := 10;
        Result := I > 5;
        Assert.IsTrue(Result, 'Boolean variable assigned from comparison expression must be true');
    end;

    [Test]
    procedure If_AssignmentInCondition_NotSupported()
    var
        I: Integer;
        Found: Boolean;
    begin
        Cleanup.Initialize();

        I := 42;
        Found := I = 42;
        Assert.IsTrue(Found, 'I = 42 comparison must be true');
    end;

    [Test]
    procedure If_TernaryEquivalent_Via_IfThenElse()
    var
        I: Integer;
        Result: Text;
    begin
        Cleanup.Initialize();

        I := 7;
        Result := Ternary(I > 5, 'big', 'small');
        Assert.AreEqual('big', Result, 'Ternary equivalent: I=7 > 5 must return "big"');
    end;

    [Test]
    procedure If_NegatedCondition()
    var
        B: Boolean;
        Result: Text;
    begin
        Cleanup.Initialize();

        B := false;
        if not B then
            Result := 'not-false'
        else
            Result := 'false';

        Assert.AreEqual('not-false', Result, 'if not false must execute then branch');
    end;

    local procedure Ternary(Condition: Boolean; ThenVal: Text; ElseVal: Text): Text
    begin
        if Condition then
            exit(ThenVal)
        else
            exit(ElseVal);
    end;
}
