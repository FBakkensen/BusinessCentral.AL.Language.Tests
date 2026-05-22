codeunit 60102 "Test JsonObject"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure JsonObject_Add_Get_TextValue()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.Add('key', 'hello');

        // Act
        JObj.Get('key', JTok);

        // Assert
        Assert.AreEqual('hello', JTok.AsValue().AsText(), 'JsonObject should store and retrieve text value');
    end;

    [Test]
    procedure JsonObject_Add_Get_IntegerValue()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.Add('num', 42);

        // Act
        JObj.Get('num', JTok);

        // Assert
        Assert.AreEqual(42, JTok.AsValue().AsInteger(), 'JsonObject should store and retrieve integer value');
    end;

    [Test]
    procedure JsonObject_Add_Get_BooleanValue()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.Add('flag', true);

        // Act
        JObj.Get('flag', JTok);

        // Assert
        Assert.IsTrue(JTok.AsValue().AsBoolean(), 'JsonObject should store and retrieve boolean value as true');
    end;

    [Test]
    procedure JsonObject_Contains_ExistingKey_ReturnsTrue()
    var
        JObj: JsonObject;
    begin
        // Arrange
        Initialize();
        JObj.Add('x', 1);

        // Act & Assert
        Assert.IsTrue(JObj.Contains('x'), 'JsonObject.Contains should return true for existing key');
    end;

    [Test]
    procedure JsonObject_Contains_MissingKey_ReturnsFalse()
    var
        JObj: JsonObject;
    begin
        // Arrange
        Initialize();

        // Act & Assert
        Assert.IsFalse(JObj.Contains('missing'), 'JsonObject.Contains should return false for missing key');
    end;

    [Test]
    procedure JsonObject_Get_MissingKey_ReturnsFalse()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        Success: Boolean;
    begin
        // Arrange
        Initialize();

        // Act
        Success := JObj.Get('nothere', JTok);

        // Assert
        Assert.IsFalse(Success, 'JsonObject.Get should return false when key does not exist');
    end;

    [Test]
    procedure JsonObject_WriteTo_SerializesJSON()
    var
        JObj: JsonObject;
        S: Text;
    begin
        // Arrange
        Initialize();
        JObj.Add('k', 'v');

        // Act
        JObj.WriteTo(S);

        // Assert
        Assert.IsTrue(S.Contains('"k"'), 'JsonObject.WriteTo should serialize to JSON string containing key');
    end;

    [Test]
    procedure JsonObject_ReadFrom_ParsesJSON()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();

        // Act
        JObj.ReadFrom('{"name":"Bob","age":25}');
        JObj.Get('name', JTok);

        // Assert
        Assert.AreEqual('Bob', JTok.AsValue().AsText(), 'JsonObject.ReadFrom should parse JSON string and retrieve value');
    end;

    [Test]
    procedure JsonObject_Remove_DeletesKey()
    var
        JObj: JsonObject;
    begin
        // Arrange
        Initialize();
        JObj.Add('a', 1);

        // Act
        JObj.Remove('a');

        // Assert
        Assert.IsFalse(JObj.Contains('a'), 'JsonObject.Remove should delete the key from object');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
