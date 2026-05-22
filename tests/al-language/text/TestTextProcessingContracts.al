codeunit 60157 "Test Text Processing Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;

    // ============================================================================
    // StrPos tests
    // ============================================================================

    [Test]
    procedure StrPos_AtPositionOne_ReturnsOne()
    begin
        Initialize();
        Assert.AreEqual(1, StrPos('hello', 'h'), 'StrPos must return 1 when found at position 1 (1-based)');
    end;

    [Test]
    procedure StrPos_NotFound_ReturnsZero()
    begin
        Initialize();
        Assert.AreEqual(0, StrPos('hello', 'z'), 'StrPos must return 0 when substring not found');
    end;

    [Test]
    procedure StrPos_EmptySubstring_ReturnsOne()
    begin
        Initialize();
        Assert.AreEqual(1, StrPos('hello', ''), 'StrPos with empty search string must return 1');
    end;

    // ============================================================================
    // CopyStr tests
    // ============================================================================

    [Test]
    procedure CopyStr_PositionBeyondLength_ReturnsEmpty()
    begin
        Initialize();
        Assert.AreEqual('', CopyStr('abc', 5), 'CopyStr starting beyond string length must return empty string');
    end;

    [Test]
    procedure CopyStr_PositionZero_ReturnsEmptyOrFull()
    var
        S: Text;
    begin
        Initialize();
        S := CopyStr('abc', 0);
        Assert.IsTrue((S = '') or (S = 'abc'), 'CopyStr(str, 0) must return either empty or full string — not throw');
    end;

    // ============================================================================
    // PadStr tests
    // ============================================================================

    [Test]
    procedure PadStr_LengthLessThanStringLen_Truncates()
    begin
        Initialize();
        Assert.AreEqual('abcd', PadStr('abcdef', 4, ' '), 'PadStr with length < StrLen must truncate to that length');
    end;

    [Test]
    procedure PadStr_LengthEqualsStringLen_Unchanged()
    begin
        Initialize();
        Assert.AreEqual('hello', PadStr('hello', 5, ' '), 'PadStr with length = StrLen must leave string unchanged');
    end;

    // ============================================================================
    // DelChr tests
    // ============================================================================

    [Test]
    procedure DelChr_LeadingTrailingSpaces_RemovesBoth()
    begin
        Initialize();
        Assert.AreEqual('hello', DelChr('  hello  ', '<>', ' '), 'DelChr(<>) must remove both leading and trailing spaces');
    end;

    [Test]
    procedure DelChr_SpacesOnly_ReturnsEmpty()
    begin
        Initialize();
        Assert.AreEqual('', DelChr('   ', '<>', ' '), 'DelChr on string of only spaces must return empty string');
    end;

    // ============================================================================
    // ConvertStr tests
    // ============================================================================

    [Test]
    procedure ConvertStr_Swap_IsSimultaneous()
    var
        S: Text;
    begin
        Initialize();
        S := ConvertStr('ab', 'ab', 'ba');
        Assert.AreEqual('ba', S, 'ConvertStr must replace characters simultaneously (ab with mapping a→b,b→a gives ba)');
    end;

    // ============================================================================
    // IncStr tests
    // ============================================================================

    [Test]
    procedure IncStr_NonNumericString_AppendOne()
    begin
        Initialize();
        Assert.AreEqual('ABC1', IncStr('ABC'), 'IncStr on non-numeric string must append 1');
    end;

    [Test]
    procedure IncStr_NumericRollover_PreservesWidth()
    begin
        Initialize();
        Assert.AreEqual('Item 010', IncStr('Item 009'), 'IncStr must increment with leading zeros preserved (009→010)');
    end;

    // ============================================================================
    // SelectStr tests
    // ============================================================================

    [Test]
    procedure SelectStr_IndexZero_ReturnsEmpty()
    begin
        Initialize();
        Assert.AreEqual('', SelectStr(0, 'A,B,C'), 'SelectStr with index 0 must return empty string');
    end;

    [Test]
    procedure SelectStr_IndexBeyondCount_ReturnsEmpty()
    begin
        Initialize();
        Assert.AreEqual('', SelectStr(5, 'A,B,C'), 'SelectStr with index > count must return empty string');
    end;

    // ============================================================================
    // Text.Contains tests
    // ============================================================================

    [Test]
    procedure Text_Contains_IsCaseSensitive()
    var
        S: Text;
    begin
        Initialize();
        S := 'Hello World';
        Assert.IsTrue(S.Contains('World'), 'Contains must find exact case match');
        Assert.IsFalse(S.Contains('world'), 'Contains must be case-sensitive — lowercase world not in Hello World');
    end;

    // ============================================================================
    // Text.IndexOf tests
    // ============================================================================

    [Test]
    procedure Text_IndexOf_NotFound_ReturnsNegativeOne()
    var
        Pos: Integer;
    begin
        Initialize();
        Pos := 'hello'.IndexOf('z');
        Assert.AreEqual(-1, Pos, 'Text.IndexOf must return -1 when substring not found');
    end;

    [Test]
    procedure Text_IndexOf_FoundAtStart_ReturnsZero()
    var
        Pos: Integer;
    begin
        Initialize();
        Pos := 'hello'.IndexOf('h');
        Assert.AreEqual(0, Pos, 'Text.IndexOf must return 0 for match at start (0-based)');
    end;

    // ============================================================================
    // TextBuilder tests
    // ============================================================================

    [Test]
    procedure TextBuilder_Insert_AtZero_Prepends()
    var
        TB: TextBuilder;
    begin
        Initialize();
        TB.Append('world');
        TB.Insert(0, 'hello ');
        Assert.AreEqual('hello world', TB.ToText(), 'TextBuilder.Insert(0, ...) must prepend text');
    end;

    // ============================================================================
    // StrSubstNo tests
    // ============================================================================

    [Test]
    procedure StrSubstNo_FewerArgsThanPlaceholders_NoError()
    var
        S: Text;
    begin
        Initialize();
        S := StrSubstNo('%1 and %2', 'Alpha');
        Assert.IsTrue(StrPos(S, 'Alpha') > 0, 'StrSubstNo must include first argument');
        Assert.IsTrue((S = 'Alpha and ') or (StrPos(S, 'and') > 0), 'StrSubstNo with missing arg must not throw');
    end;
}
