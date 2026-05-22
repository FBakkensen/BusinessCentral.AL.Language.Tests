codeunit 60087 "Test Text Operations"
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
    procedure Text_CopyStr_ExtractsSubstring()
    var
        Result: Text;
    begin
        Initialize();
        Result := CopyStr('hello', 2);
        Assert.AreEqual('ello', Result, 'CopyStr from position 2 must extract "ello"');
    end;

    [Test]
    procedure Text_CopyStr_WithLength_LimitsResult()
    var
        Result: Text;
    begin
        Initialize();
        Result := CopyStr('hello', 1, 3);
        Assert.AreEqual('hel', Result, 'CopyStr with length 3 must return "hel"');
    end;

    [Test]
    procedure Text_StrLen_ReturnsLength()
    var
        Len: Integer;
    begin
        Initialize();
        Len := StrLen('hello');
        Assert.AreEqual(5, Len, 'StrLen of "hello" must return 5');
    end;

    [Test]
    procedure Text_StrPos_FindsSubstring()
    var
        Pos: Integer;
    begin
        Initialize();
        Pos := StrPos('hello', 'llo');
        Assert.AreEqual(3, Pos, 'StrPos must find "llo" at position 3');
    end;

    [Test]
    procedure Text_StrPos_NotFound_ReturnsZero()
    var
        Pos: Integer;
    begin
        Initialize();
        Pos := StrPos('hello', 'xyz');
        Assert.AreEqual(0, Pos, 'StrPos for non-existent substring must return 0');
    end;

    [Test]
    procedure Text_UpperCase_ConvertsToUpper()
    var
        Result: Text;
    begin
        Initialize();
        Result := UpperCase('hello');
        Assert.AreEqual('HELLO', Result, 'UpperCase must convert "hello" to "HELLO"');
    end;

    [Test]
    procedure Text_LowerCase_ConvertsToLower()
    var
        Result: Text;
    begin
        Initialize();
        Result := LowerCase('HELLO');
        Assert.AreEqual('hello', Result, 'LowerCase must convert "HELLO" to "hello"');
    end;

    [Test]
    procedure Text_DelStr_RemovesSubstring()
    var
        Result: Text;
    begin
        Initialize();
        Result := DelStr('Hello', 2, 1);
        Assert.AreEqual('Hllo', Result, 'DelStr must remove 1 character at position 2');
    end;

    [Test]
    procedure Text_InsStr_InsertsSubstring()
    var
        Result: Text;
    begin
        Initialize();
        Result := InsStr('Hello', 'x', 2);
        Assert.AreEqual('Hxello', Result, 'InsStr must insert "x" at position 2');
    end;

    [Test]
    procedure Text_PadStr_PadsToLength()
    var
        Result: Text;
    begin
        Initialize();
        Result := PadStr('hi', 5, ' ');
        Assert.AreEqual('hi   ', Result, 'PadStr must pad "hi" to length 5 with spaces');
    end;
}
