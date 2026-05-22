codeunit 60089 "Test BigText"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;
    [Test]
    procedure BigText_AddText_PreservesData()
    var
        BT: BigText;
        Sub: Text;
    begin
        Initialize();
        BT.AddText('TestData');
        BT.GetSubText(Sub, 1, 8);
        Assert.AreEqual('TestData', Sub, 'BigText GetSubText must return added text');
    end;

    local procedure Initialize()
    begin
        // Harmless initialization
    end;

    [Test]
    procedure BigText_AddText_IncreasesLength()
    var
        BT: BigText;
        Len: Integer;
    begin
        Initialize();
        BT.AddText('hello world');
        Len := BT.Length();
        Assert.IsTrue(Len > 0, 'BigText.Length after AddText must be greater than 0');
    end;

    [Test]
    procedure BigText_Length_ReturnsCorrectLength()
    var
        BT: BigText;
        Len: Integer;
    begin
        Initialize();
        BT.AddText('12345');
        Len := BT.Length();
        Assert.AreEqual(5, Len, 'BigText.Length after AddText("12345") must return 5');
    end;

    [Test]
    procedure BigText_GetSubText_ExtractsChars()
    var
        BT: BigText;
        Extracted: Text;
    begin
        Initialize();
        BT.AddText('Hello World');
        BT.GetSubText(Extracted, 1, 5);
        Assert.AreEqual('Hello', Extracted, 'BigText.GetSubText(1, 5) must extract "Hello"');
    end;

        [Test]
    procedure BigText_AddText_Twice_Appends()
    var
        BT: BigText;
        Len: Integer;
    begin
        Initialize();
        BT.AddText('foo');
        BT.AddText('bar');
        Len := BT.Length();
        Assert.AreEqual(6, Len, 'BigText after two AddText calls must have combined length 6');
    end;

    [Test]
    procedure BigText_GetSubText_FullRange_ReturnsFullText()
    var
        BT: BigText;
        Sub: Text;
    begin
        Initialize();
        BT.AddText('ab');
        BT.GetSubText(Sub, 1, 2);
        Assert.AreEqual('ab', Sub, 'BigText.GetSubText of full range must return full text');
    end;
}
