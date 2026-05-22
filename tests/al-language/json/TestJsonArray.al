codeunit 60103 "Test JsonArray"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure JsonArray_Add_Count_IncreasesCount()
    var
        JArr: JsonArray;
    begin
        // Arrange
        Initialize();

        // Act
        JArr.Add(1);

        // Assert
        Assert.AreEqual(1, JArr.Count(), 'JsonArray.Count should be 1 after adding one element');
    end;

    [Test]
    procedure JsonArray_Add_Multiple_CountMatches()
    var
        JArr: JsonArray;
    begin
        // Arrange
        Initialize();

        // Act
        JArr.Add(1);
        JArr.Add(2);
        JArr.Add(3);

        // Assert
        Assert.AreEqual(3, JArr.Count(), 'JsonArray.Count should match number of added elements');
    end;

    [Test]
    procedure JsonArray_Get_ByIndex_ReturnsValue()
    var
        JArr: JsonArray;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JArr.Add('first');
        JArr.Add('second');

        // Act
        JArr.Get(0, JTok);

        // Assert
        Assert.AreEqual('first', JTok.AsValue().AsText(), 'JsonArray.Get(0) should return first element');
    end;

    [Test]
    procedure JsonArray_Get_SecondIndex_ReturnsSecond()
    var
        JArr: JsonArray;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JArr.Add(10);
        JArr.Add(20);

        // Act
        JArr.Get(1, JTok);

        // Assert
        Assert.AreEqual(20, JTok.AsValue().AsInteger(), 'JsonArray.Get(1) should return second element');
    end;

    [Test]
    procedure JsonArray_WriteTo_ProducesArray()
    var
        JArr: JsonArray;
        S: Text;
    begin
        // Arrange
        Initialize();
        JArr.Add(1);
        JArr.Add(2);

        // Act
        JArr.WriteTo(S);

        // Assert
        Assert.IsTrue(S.Contains('['), 'JsonArray.WriteTo should produce JSON array string containing [ bracket');
    end;

    [Test]
    procedure JsonArray_ReadFrom_ParsesArray()
    var
        JArr: JsonArray;
    begin
        // Arrange
        Initialize();

        // Act
        JArr.ReadFrom('[1,2,3]');

        // Assert
        Assert.AreEqual(3, JArr.Count(), 'JsonArray.ReadFrom should parse JSON array string and set count');
    end;

    [Test]
    procedure JsonArray_ReadFrom_GetsFirstElement()
    var
        JArr: JsonArray;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();

        // Act
        JArr.ReadFrom('["a","b"]');
        JArr.Get(0, JTok);

        // Assert
        Assert.AreEqual('a', JTok.AsValue().AsText(), 'JsonArray.ReadFrom should parse array and allow retrieval of first element');
    end;

    [Test]
    procedure JsonArray_Add_JsonObject_Nested()
    var
        JArr: JsonArray;
        JInner: JsonObject;
    begin
        // Arrange
        Initialize();
        JInner.Add('id', 1);

        // Act
        JArr.Add(JInner);

        // Assert
        Assert.AreEqual(1, JArr.Count(), 'JsonArray.Add should accept JsonObject and increment count');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
