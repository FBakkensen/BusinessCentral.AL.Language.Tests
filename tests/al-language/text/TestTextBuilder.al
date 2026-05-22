codeunit 60088 "Test TextBuilder"
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
    procedure TextBuilder_Append_SingleString_Builds()
    var
        TB: TextBuilder;
        Result: Text;
    begin
        Initialize();
        TB.Append('hello');
        Result := TB.ToText();
        Assert.AreEqual('hello', Result, 'TextBuilder.Append must add "hello" to builder');
    end;

    [Test]
    procedure TextBuilder_Append_MultipleStrings_Concatenates()
    var
        TB: TextBuilder;
        Result: Text;
    begin
        Initialize();
        TB.Append('foo');
        TB.Append('bar');
        Result := TB.ToText();
        Assert.AreEqual('foobar', Result, 'TextBuilder.Append twice must concatenate "foo" and "bar"');
    end;

    [Test]
    procedure TextBuilder_AppendLine_AddsNewline()
    var
        TB: TextBuilder;
        Result: Text;
    begin
        Initialize();
        TB.AppendLine('line1');
        TB.Append('line2');
        Result := TB.ToText();
        Assert.IsTrue(Result.Contains('line1'), 'TextBuilder.AppendLine must add "line1" to output');
    end;

    [Test]
    procedure TextBuilder_Length_ReturnsCurrentLength()
    var
        TB: TextBuilder;
        Len: Integer;
    begin
        Initialize();
        TB.Append('abc');
        Len := TB.Length();
        Assert.AreEqual(3, Len, 'TextBuilder.Length after Append("abc") must return 3');
    end;

    [Test]
    procedure TextBuilder_Clear_EmptiesBuilder()
    var
        TB: TextBuilder;
        Result: Text;
    begin
        Initialize();
        TB.Append('data');
        TB.Clear();
        Result := TB.ToText();
        Assert.AreEqual('', Result, 'TextBuilder.Clear must empty the builder');
    end;

    [Test]
    procedure TextBuilder_Insert_InsertsAtPosition()
    var
        TB: TextBuilder;
        Result: Text;
    begin
        Initialize();
        TB.Append('hllo');
        TB.Insert(1, 'e');
        Result := TB.ToText();
        Assert.AreEqual('hello', Result, 'TextBuilder.Insert at position 1 must insert "e" to form "hello"');
    end;

    [Test]
    procedure TextBuilder_Remove_RemovesChars()
    var
        TB: TextBuilder;
        Result: Text;
    begin
        Initialize();
        TB.Append('hello');
        TB.Remove(1, 2);
        Result := TB.ToText();
        Assert.AreEqual('hlo', Result, 'TextBuilder.Remove(1, 2) must remove 2 chars starting at position 1');
    end;

    [Test]
    procedure TextBuilder_EnsureCapacity_DoesNotThrow()
    var
        TB: TextBuilder;
        Result: Text;
    begin
        Initialize();
        TB.EnsureCapacity(100);
        Result := TB.ToText();
        Assert.AreEqual('', Result, 'TextBuilder.EnsureCapacity must not add characters');
    end;
}
