codeunit 60104 "Test JsonToken"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure JsonToken_AsValue_FromObject_ReturnsValue()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.Add('n', 5);

        // Act
        JObj.Get('n', JTok);

        // Assert
        Assert.AreEqual(5, JTok.AsValue().AsInteger(), 'JsonToken.AsValue should return the value from a value token');
    end;

    [Test]
    procedure JsonToken_IsObject_ForObject()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.Add('x', 99);

        // Act
        JTok := JObj.AsToken();

        // Assert
        Assert.IsTrue(JTok.IsObject(), 'JsonToken.IsObject should return true for object token');
    end;

    [Test]
    procedure JsonToken_IsValue_ForTextValue()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.Add('s', 'hi');

        // Act
        JObj.Get('s', JTok);

        // Assert
        Assert.IsTrue(JTok.IsValue(), 'JsonToken.IsValue should return true for value token');
    end;

    [Test]
    procedure JsonToken_IsArray_ForArray()
    var
        JArr: JsonArray;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JArr.Add(1);

        // Act
        JTok := JArr.AsToken();

        // Assert
        Assert.IsTrue(JTok.IsArray(), 'JsonToken.IsArray should return true for array token');
    end;

    [Test]
    procedure JsonToken_Clone_CreatesIndependentCopy()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        JClone: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.Add('v', 42);
        JObj.Get('v', JTok);

        // Act
        JClone := JTok.Clone();

        // Assert
        Assert.AreEqual(42, JClone.AsValue().AsInteger(), 'JsonToken.Clone should create independent copy with same value');
    end;

    [Test]
    procedure JsonToken_AsObject_FromObjectToken_ReturnsObject()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        JAsObj: JsonObject;
        JInnerTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"a":1}');

        // Act
        JTok := JObj.AsToken();
        JAsObj := JTok.AsObject();
        JAsObj.Get('a', JInnerTok);

        // Assert
        Assert.AreEqual(1, JInnerTok.AsValue().AsInteger(), 'JsonToken.AsObject should return underlying object and allow key retrieval');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
