codeunit 60121 "Test Json Typed Getters"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ===== JsonObject typed getters =====

    [Test]
    procedure JsonObject_GetBoolean_ReturnsTrue()
    var
        JObj: JsonObject;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"flag":true}');

        // Act & Assert
        Assert.IsTrue(JObj.GetBoolean('flag'), 'JsonObject.GetBoolean must return true when value is true');
    end;

    [Test]
    procedure JsonObject_GetBoolean_ReturnsFalse()
    var
        JObj: JsonObject;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"flag":false}');

        // Act & Assert
        Assert.IsFalse(JObj.GetBoolean('flag'), 'JsonObject.GetBoolean must return false when value is false');
    end;

    [Test]
    procedure JsonObject_GetInteger_ReturnsValue()
    var
        JObj: JsonObject;
        Result: Integer;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"count":42}');

        // Act
        Result := JObj.GetInteger('count');

        // Assert
        Assert.AreEqual(42, Result, 'JsonObject.GetInteger must return 42');
    end;

    [Test]
    procedure JsonObject_GetDecimal_ReturnsValue()
    var
        JObj: JsonObject;
        Result: Decimal;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"price":2.5}');

        // Act
        Result := JObj.GetDecimal('price');

        // Assert
        Assert.IsTrue(Result > 2.0, 'JsonObject.GetDecimal must return value greater than 2.0');
    end;

    [Test]
    procedure JsonObject_GetText_ReturnsString()
    var
        JObj: JsonObject;
        Result: Text;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"name":"hello"}');

        // Act
        Result := JObj.GetText('name');

        // Assert
        Assert.AreEqual('hello', Result, 'JsonObject.GetText must return "hello"');
    end;

    [Test]
    procedure JsonObject_GetBigInteger_ReturnsValue()
    var
        JObj: JsonObject;
        Result: BigInteger;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"big":1000000}');

        // Act
        Result := JObj.GetBigInteger('big');

        // Assert
        Assert.AreEqual(1000000, Result, 'JsonObject.GetBigInteger must return 1000000');
    end;

    [Test]
    procedure JsonObject_GetBoolean_MissingKey_UsesDefault()
    var
        JObj: JsonObject;
        Result: Boolean;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"other":true}');

        // Act
        Result := JObj.GetBoolean('missing', false);

        // Assert
        Assert.AreEqual(false, Result, 'JsonObject.GetBoolean must return default false when key is missing');
    end;

    [Test]
    procedure JsonObject_GetInteger_MissingKey_UsesDefault()
    var
        JObj: JsonObject;
        Result: Integer;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"other":5}');

        // Act
        Result := JObj.GetInteger('missing');

        // Assert
        Assert.AreEqual(99, Result, 'JsonObject.GetInteger must return default 99 when key is missing');
    end;

    [Test]
    procedure JsonObject_GetDecimal_MissingKey_UsesDefault()
    var
        JObj: JsonObject;
        Result: Decimal;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"other":1.5}');

        // Act
        Result := JObj.GetDecimal('missing');

        // Assert
        Assert.AreEqual(3.14, Result, 'JsonObject.GetDecimal must return default 3.14 when key is missing');
    end;

    [Test]
    procedure JsonObject_GetText_MissingKey_UsesDefault()
    var
        JObj: JsonObject;
        Result: Text;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"other":"value"}');

        // Act
        Result := JObj.GetText('missing');

        // Assert
        Assert.AreEqual('default', Result, 'JsonObject.GetText must return default "default" when key is missing');
    end;

    // ===== JsonArray typed getters =====

    [Test]
    procedure JsonArray_GetBoolean_ReturnsTrue()
    var
        JArr: JsonArray;
    begin
        // Arrange
        Initialize();
        JArr.ReadFrom('[true,false]');

        // Act & Assert
        Assert.IsTrue(JArr.GetBoolean(0), 'JsonArray.GetBoolean(0) must return true for first element');
    end;

    [Test]
    procedure JsonArray_GetBoolean_ReturnsFalse()
    var
        JArr: JsonArray;
    begin
        // Arrange
        Initialize();
        JArr.ReadFrom('[true,false]');

        // Act & Assert
        Assert.IsFalse(JArr.GetBoolean(1), 'JsonArray.GetBoolean(1) must return false for second element');
    end;

    [Test]
    procedure JsonArray_GetInteger_ReturnsValue()
    var
        JArr: JsonArray;
        Result: Integer;
    begin
        // Arrange
        Initialize();
        JArr.ReadFrom('[10,20,30]');

        // Act
        Result := JArr.GetInteger(1);

        // Assert
        Assert.AreEqual(20, Result, 'JsonArray.GetInteger(1) must return 20');
    end;

    [Test]
    procedure JsonArray_GetDecimal_ReturnsValue()
    var
        JArr: JsonArray;
        Result: Decimal;
    begin
        // Arrange
        Initialize();
        JArr.ReadFrom('[1.5,2.5]');

        // Act
        Result := JArr.GetDecimal(0);

        // Assert
        Assert.IsTrue(Result > 1.0, 'JsonArray.GetDecimal(0) must return value greater than 1.0');
    end;

    [Test]
    procedure JsonArray_GetText_ReturnsString()
    var
        JArr: JsonArray;
        Result: Text;
    begin
        // Arrange
        Initialize();
        JArr.ReadFrom('["apple","banana"]');

        // Act
        Result := JArr.GetText(0);

        // Assert
        Assert.AreEqual('apple', Result, 'JsonArray.GetText(0) must return "apple"');
    end;

    [Test]
    procedure JsonArray_GetBigInteger_ReturnsValue()
    var
        JArr: JsonArray;
        Result: BigInteger;
    begin
        // Arrange
        Initialize();
        JArr.ReadFrom('[999999]');

        // Act
        Result := JArr.GetBigInteger(0);

        // Assert
        Assert.AreEqual(999999, Result, 'JsonArray.GetBigInteger(0) must return 999999');
    end;

    // ===== JsonValue As* methods =====

    [Test]
    procedure JsonValue_AsBigInteger_ReturnsValue()
    var
        JVal: JsonValue;
        Result: BigInteger;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(42);

        // Act
        Result := JVal.AsBigInteger();

        // Assert
        Assert.AreEqual(42, Result, 'JsonValue.AsBigInteger must return 42');
    end;

    [Test]
    procedure JsonValue_AsByte_ReturnsValue()
    var
        JVal: JsonValue;
        Result: Byte;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(100);

        // Act
        Result := JVal.AsByte();

        // Assert
        Assert.AreEqual(100, Result, 'JsonValue.AsByte must return 100');
    end;

    [Test]
    procedure JsonValue_AsCode_ReturnsValue()
    var
        JVal: JsonValue;
        Result: Code[100];
    begin
        // Arrange
        Initialize();
        JVal.SetValue('ITEM001');

        // Act
        Result := JVal.AsCode();

        // Assert
        Assert.AreEqual('ITEM001', Result, 'JsonValue.AsCode must return "ITEM001"');
    end;

    [Test]
    procedure JsonValue_AsDate_ReturnsDate()
    var
        JVal: JsonValue;
        Result: Date;
        ExpectedDate: Date;
    begin
        // Arrange
        Initialize();
        ExpectedDate := Today();
        JVal.SetValue(ExpectedDate);

        // Act
        Result := JVal.AsDate();

        // Assert
        Assert.AreEqual(ExpectedDate, Result, 'JsonValue.AsDate must return the date value');
    end;

    [Test]
    procedure JsonValue_AsDateTime_ReturnsDateTime()
    var
        JVal: JsonValue;
        Result: DateTime;
        ExpectedDateTime: DateTime;
    begin
        // Arrange
        Initialize();
        ExpectedDateTime := CreateDateTime(Today(), 120000T);
        JVal.SetValue(ExpectedDateTime);

        // Act
        Result := JVal.AsDateTime();

        // Assert
        Assert.AreEqual(ExpectedDateTime, Result, 'JsonValue.AsDateTime must return the datetime value');
    end;

    [Test]
    procedure JsonValue_AsDuration_ReturnsValue()
    var
        JVal: JsonValue;
        Result: Duration;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(5000);

        // Act
        Result := JVal.AsDuration();

        // Assert
        Assert.IsTrue(Result > 0, 'JsonValue.AsDuration must return positive duration');
    end;

    // ===== JsonToken As* and Is* methods =====

    [Test]
    procedure JsonToken_AsArray_ReturnsArray()
    var
        JArr: JsonArray;
        JTok: JsonToken;
        Result: JsonArray;
    begin
        // Arrange
        Initialize();
        JArr.ReadFrom('[1,2,3]');
        JTok := JArr.AsToken();

        // Act
        Result := JTok.AsArray();

        // Assert
        Assert.AreEqual(3, Result.Count(), 'JsonToken.AsArray must return array with count 3');
    end;

    [Test]
    procedure JsonToken_SelectToken_FindsNestedValue()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        Selected: JsonToken;
        Result: Integer;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"a":{"b":{"c":42}}}');
        JTok := JObj.AsToken();

        // Act
        JTok.SelectToken('a.b.c', Selected);
        Result := Selected.AsValue().AsInteger();

        // Assert
        Assert.AreEqual(42, Result, 'JsonToken.SelectToken must find nested value 42 at path a.b.c');
    end;

    [Test]
    procedure JsonToken_IsValue_ForBoolean()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"flag":true}');
        JObj.Get('flag', JTok);

        // Act & Assert
        Assert.IsTrue(JTok.IsValue(), 'JsonToken.IsValue must return true for boolean value token');
    end;

    [Test]
    procedure JsonToken_IsValue_ForInteger()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"num":99}');
        JObj.Get('num', JTok);

        // Act & Assert
        Assert.IsTrue(JTok.IsValue(), 'JsonToken.IsValue must return true for integer value token');
    end;

    [Test]
    procedure JsonToken_IsObject_ForNestedObject()
    var
        JObj: JsonObject;
        JInner: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JInner.Add('x', 5);
        JObj.Add('inner', JInner);
        JObj.Get('inner', JTok);

        // Act & Assert
        Assert.IsTrue(JTok.IsObject(), 'JsonToken.IsObject must return true for nested object token');
    end;

    [Test]
    procedure JsonToken_IsArray_ForNestedArray()
    var
        JObj: JsonObject;
        JArr: JsonArray;
        JTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JArr.Add(1);
        JArr.Add(2);
        JObj.Add('items', JArr);
        JObj.Get('items', JTok);

        // Act & Assert
        Assert.IsTrue(JTok.IsArray(), 'JsonToken.IsArray must return true for nested array token');
    end;

    [Test]
    procedure JsonToken_Path_ReturnsPath()
    var
        JObj: JsonObject;
        JInner: JsonObject;
        JTok: JsonToken;
        PathResult: Text;
    begin
        // Arrange
        Initialize();
        JInner.Add('id', 1);
        JObj.Add('nested', JInner);
        JObj.Get('nested', JTok);

        // Act
        PathResult := JTok.Path();

        // Assert
        Assert.IsTrue(PathResult.Contains('nested'), 'JsonToken.Path must return path containing "nested"');
    end;

    [Test]
    procedure JsonToken_AsObject_FromObjectToken()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        ResultObj: JsonObject;
        InnerTok: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"value":77}');
        JTok := JObj.AsToken();

        // Act
        ResultObj := JTok.AsObject();
        ResultObj.Get('value', InnerTok);

        // Assert
        Assert.AreEqual(77, InnerTok.AsValue().AsInteger(), 'JsonToken.AsObject must return object allowing key retrieval');
    end;

    [Test]
    procedure JsonToken_SelectToken_FindsArrayElement()
    var
        JObj: JsonObject;
        JArr: JsonArray;
        JTok: JsonToken;
        Selected: JsonToken;
        Result: Integer;
    begin
        // Arrange
        Initialize();
        JArr.Add(100);
        JArr.Add(200);
        JObj.Add('items', JArr);
        JTok := JObj.AsToken();

        // Act
        JTok.SelectToken('items[0]', Selected);
        Result := Selected.AsValue().AsInteger();

        // Assert
        Assert.AreEqual(100, Result, 'JsonToken.SelectToken must find array element at items[0]');
    end;

    [Test]
    procedure JsonObject_GetInteger_WithDifferentValues()
    var
        JObj: JsonObject;
        Result1: Integer;
        Result2: Integer;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"first":10,"second":20}');

        // Act
        Result1 := JObj.GetInteger('first');
        Result2 := JObj.GetInteger('second');

        // Assert
        Assert.AreEqual(10, Result1, 'JsonObject.GetInteger for first key must return 10');
        Assert.AreEqual(20, Result2, 'JsonObject.GetInteger for second key must return 20');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
