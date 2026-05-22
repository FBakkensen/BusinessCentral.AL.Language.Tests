codeunit 60090 "Test Format"
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
    procedure Format_Integer_ReturnsString()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(42);
        Assert.AreEqual('42', Result, 'Format(42) must return "42"');
    end;

    [Test]
    procedure Format_Decimal_ReturnsString()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(3.14);
        Assert.AreNotEqual('', Result, 'Format(3.14) must return non-empty string');
    end;

    [Test]
    procedure Format_Boolean_True_ReturnsTrue()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(true);
        Assert.AreEqual('true', LowerCase(Result), 'Format(true) must return string "true" or "True"');
    end;

    [Test]
    procedure Format_Date_ReturnsNonEmpty()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(Today());
        Assert.AreNotEqual('', Result, 'Format(Today()) must return non-empty date string');
    end;

    [Test]
    procedure Format_WithLength_RightAligns()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(42, 5);
        Assert.AreEqual('   42', Result, 'Format(42, 5) must right-align in 5 characters');
    end;

    [Test]
    procedure Format_Negative_Integer()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(-7);
        Assert.AreEqual('-7', Result, 'Format(-7) must return "-7"');
    end;

    [Test]
    procedure Format_Zero_Integer()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format(0);
        Assert.AreEqual('0', Result, 'Format(0) must return "0"');
    end;

    [Test]
    procedure Format_Code_ReturnsCode()
    var
        Result: Text;
    begin
        Initialize();
        Result := Format('ABC');
        Assert.AreEqual('ABC', Result, 'Format("ABC") must return "ABC"');
    end;
}
