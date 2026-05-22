// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-contains--method
// Scope: in-scope
// Runtime: 16.1, Target: Cloud
// String methods (Text type methods, not global functions)

codeunit 60191 "Test String Method Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Text.Contains() ─────────────────────────────────────────────────────

    [Test]
    procedure Text_Contains_CaseSensitive_True()
    var
        TestString: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Assert.IsTrue(TestString.Contains('World'), 'Contains must find exact case match');
    end;

    [Test]
    procedure Text_Contains_CaseSensitive_False()
    var
        TestString: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Assert.IsFalse(TestString.Contains('world'), 'Contains is case-sensitive: lowercase not found in mixed case');
    end;

    // ── Text.StartsWith() ───────────────────────────────────────────────────

    [Test]
    procedure Text_StartsWith_True()
    var
        TestString: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Assert.IsTrue(TestString.StartsWith('Hello'), 'StartsWith must return true for matching prefix');
    end;

    [Test]
    procedure Text_StartsWith_False()
    var
        TestString: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Assert.IsFalse(TestString.StartsWith('World'), 'StartsWith must return false for non-prefix');
    end;

    // ── Text.EndsWith() ─────────────────────────────────────────────────────

    [Test]
    procedure Text_EndsWith_True()
    var
        TestString: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Assert.IsTrue(TestString.EndsWith('World'), 'EndsWith must return true for matching suffix');
    end;

    [Test]
    procedure Text_EndsWith_False()
    var
        TestString: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Assert.IsFalse(TestString.EndsWith('Hello'), 'EndsWith must return false for non-suffix');
    end;

    // ── Text.ToUpper() ──────────────────────────────────────────────────────

    [Test]
    procedure Text_ToUpper_ConvertsAll()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'Hello World 123';
        Result := TestString.ToUpper();
        Assert.AreEqual('HELLO WORLD 123', Result, 'ToUpper must uppercase all letters');
    end;

    // ── Text.ToLower() ──────────────────────────────────────────────────────

    [Test]
    procedure Text_ToLower_ConvertsAll()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'Hello World 123';
        Result := TestString.ToLower();
        Assert.AreEqual('hello world 123', Result, 'ToLower must lowercase all letters');
    end;

    // ── Text.Trim() ─────────────────────────────────────────────────────────

    [Test]
    procedure Text_Trim_RemovesLeadingAndTrailing()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := '  hello  ';
        Result := TestString.Trim();
        Assert.AreEqual('hello', Result, 'Trim must remove leading and trailing spaces');
    end;

    // ── Text.TrimStart() ────────────────────────────────────────────────────

    [Test]
    procedure Text_TrimStart_RemovesLeadingOnly()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := '  hello  ';
        Result := TestString.TrimStart();
        Assert.AreEqual('hello  ', Result, 'TrimStart must remove only leading spaces');
    end;

    // ── Text.TrimEnd() ──────────────────────────────────────────────────────

    [Test]
    procedure Text_TrimEnd_RemovesTrailingOnly()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := '  hello  ';
        Result := TestString.TrimEnd();
        Assert.AreEqual('  hello', Result, 'TrimEnd must remove only trailing spaces');
    end;

    // ── Text.Replace() ──────────────────────────────────────────────────────

    [Test]
    procedure Text_Replace_SubstituteAll()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'hello';
        Result := TestString.Replace('e', 'X').Replace('o', 'X');
        Assert.AreEqual('hXllX', Result, 'Replace must substitute all occurrences');
    end;

    // ── Text.Substring(StartIndex: Integer) ─────────────────────────────────

    [Test]
    procedure Text_Substring_FromIndex()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Result := TestString.Substring(6);
        Assert.AreEqual('World', Result, 'Substring(6) from 0-based index 6 must return "World"');
    end;

    // ── Text.Substring(StartIndex: Integer; Length: Integer) ────────────────

    [Test]
    procedure Text_Substring_WithLength()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'Hello World';
        Result := TestString.Substring(0, 5);
        Assert.AreEqual('Hello', Result, 'Substring(0,5) must return first 5 chars');
    end;

    // ── Text.IndexOf() ──────────────────────────────────────────────────────

    [Test]
    procedure Text_IndexOf_Found_ZeroBased()
    var
        TestString: Text;
        Result: Integer;
    begin
        Initialize();
        TestString := 'Hello World';
        Result := TestString.IndexOf('World');
        Assert.AreEqual(6, Result, 'IndexOf returns 0-based index: "World" starts at index 6');
    end;

    [Test]
    procedure Text_IndexOf_NotFound_MinusOne()
    var
        TestString: Text;
        Result: Integer;
    begin
        Initialize();
        TestString := 'Hello';
        Result := TestString.IndexOf('xyz');
        Assert.AreEqual(-1, Result, 'IndexOf returns -1 when not found');
    end;

    // ── Text.Split() ────────────────────────────────────────────────────────

    [Test]
    procedure Text_Split_ByComma()
    var
        TestString: Text;
        Parts: List of [Text];
    begin
        Initialize();
        TestString := 'a,b,c';
        Parts := TestString.Split(',');
        Assert.AreEqual(3, Parts.Count(), 'Split(",") must return 3 parts');
        Assert.AreEqual('a', Parts.Get(1), 'First part must be "a"');
        Assert.AreEqual('c', Parts.Get(3), 'Third part must be "c"');
    end;

    // ── Text.PadLeft() ──────────────────────────────────────────────────────

    [Test]
    procedure Text_PadLeft_PadsWithSpace()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'hi';
        Result := TestString.PadLeft(5);
        Assert.AreEqual('   hi', Result, 'PadLeft(5) must pad "hi" to 5 chars');
    end;

    // ── Text.PadRight() ─────────────────────────────────────────────────────

    [Test]
    procedure Text_PadRight_PadsWithSpace()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'hi';
        Result := TestString.PadRight(5);
        Assert.AreEqual('hi   ', Result, 'PadRight(5) must pad "hi" to 5 chars');
    end;

    // ── Text.PadLeft(Length: Integer; PadChar: Char) ────────────────────────

    [Test]
    procedure Text_PadLeft_WithChar()
    var
        TestString: Text;
        Result: Text;
    begin
        Initialize();
        TestString := 'hi';
        Result := TestString.PadLeft(5, '#');
        Assert.AreEqual('###hi', Result, 'PadLeft(5,"#") must pad with "#"');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
