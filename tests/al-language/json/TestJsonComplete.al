codeunit 60140 "Test Json Complete"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ===== JsonObject remaining typed getters =====

    [Test]
    procedure JsonObject_GetByte_ReturnsValue()
    var
        JObj: JsonObject;
        B: Byte;
    begin
        Initialize();
        JObj.ReadFrom('{"b":200}');
        B := JObj.GetByte('b');
        Assert.AreEqual(200, B, 'JsonObject.GetByte must return 200');
    end;

    [Test]
    procedure JsonObject_GetDate_ReturnsDate()
    var
        JObj: JsonObject;
        D: Date;
    begin
        Initialize();
        JObj.ReadFrom('{"d":"2024-01-15"}');
        D := JObj.GetDate('d');
        Assert.AreNotEqual(0D, D, 'JsonObject.GetDate must return non-zero Date');
    end;

    [Test]
    procedure JsonObject_GetDateTime_ReturnsDateTime()
    var
        JObj: JsonObject;
        DT: DateTime;
    begin
        Initialize();
        JObj.ReadFrom('{"dt":"2024-01-15T12:00:00"}');
        DT := JObj.GetDateTime('dt');
        Assert.AreNotEqual(0DT, DT, 'JsonObject.GetDateTime must return non-zero DateTime');
    end;

    [Test]
    procedure JsonObject_GetDuration_ReturnsDuration()
    var
        JObj: JsonObject;
        Dur: Duration;
    begin
        Initialize();
        JObj.ReadFrom('{"dur":3600000}');
        Dur := JObj.GetDuration('dur');
        Assert.IsTrue(Dur > 0, 'JsonObject.GetDuration must return value greater than 0');
    end;

    [Test]
    procedure JsonObject_GetArray_ReturnsArray()
    var
        JObj: JsonObject;
        Inner: JsonArray;
    begin
        Initialize();
        JObj.ReadFrom('{"arr":[1,2,3]}');
        Inner := JObj.GetArray('arr');
        Assert.AreEqual(3, Inner.Count(), 'JsonObject.GetArray must return array with Count=3');
    end;

    [Test]
    procedure JsonObject_GetObject_ReturnsObject()
    var
        JObj: JsonObject;
        Inner: JsonObject;
        X: Integer;
    begin
        Initialize();
        JObj.ReadFrom('{"obj":{"x":1}}');
        Inner := JObj.GetObject('obj');
        X := Inner.GetInteger('x');
        Assert.AreEqual(1, X, 'JsonObject.GetObject must return nested object with x=1');
    end;

    [Test]
    procedure JsonObject_GetTime_ReturnsTime()
    var
        JObj: JsonObject;
        T: Time;
    begin
        Initialize();
        JObj.ReadFrom('{"t":"12:00:00"}');
        T := JObj.GetTime('t');
        Assert.AreNotEqual(0T, T, 'JsonObject.GetTime must return non-zero Time');
    end;

    [Test]
    procedure JsonObject_GetOption_ReturnsInteger()
    var
        JObj: JsonObject;
        Opt: Integer;
    begin
        Initialize();
        JObj.ReadFrom('{"o":2}');
        Opt := JObj.GetOption('o');
        Assert.AreEqual(2, Opt, 'JsonObject.GetOption must return 2');
    end;

    // ===== JsonArray remaining typed getters =====

    [Test]
    procedure JsonArray_GetByte_ReturnsValue()
    var
        JArr: JsonArray;
        B: Byte;
    begin
        Initialize();
        JArr.ReadFrom('[100,200]');
        B := JArr.GetByte(0);
        Assert.AreEqual(100, B, 'JsonArray.GetByte must return 100 from first element');
    end;

    [Test]
    procedure JsonArray_GetDate_ReturnsDate()
    var
        JArr: JsonArray;
        D: Date;
    begin
        Initialize();
        JArr.Add(Today());
        D := JArr.GetDate(0);
        Assert.AreNotEqual(0D, D, 'JsonArray.GetDate must return non-zero Date');
    end;

    [Test]
    procedure JsonArray_GetDateTime_ReturnsDateTime()
    var
        JArr: JsonArray;
        DT: DateTime;
    begin
        Initialize();
        JArr.Add(CurrentDateTime());
        DT := JArr.GetDateTime(0);
        Assert.AreNotEqual(0DT, DT, 'JsonArray.GetDateTime must return non-zero DateTime');
    end;

    [Test]
    procedure JsonArray_GetDuration_ReturnsDuration()
    var
        JArr: JsonArray;
        Dur: Duration;
    begin
        Initialize();
        Dur := 86400000;
        JArr.Add(Dur);
        Assert.IsTrue(JArr.GetDuration(0) > 0, 'JsonArray.GetDuration must return value greater than 0');
    end;

    [Test]
    procedure JsonArray_GetArray_ReturnsNested()
    var
        JArr: JsonArray;
        Inner: JsonArray;
    begin
        Initialize();
        JArr.ReadFrom('[[1,2],[3]]');
        Inner := JArr.GetArray(0);
        Assert.AreEqual(2, Inner.Count(), 'JsonArray.GetArray must return nested array with Count=2');
    end;

    [Test]
    procedure JsonArray_GetObject_ReturnsObject()
    var
        JArr: JsonArray;
        Inner: JsonObject;
        Id: Integer;
    begin
        Initialize();
        JArr.ReadFrom('[{"id":1}]');
        Inner := JArr.GetObject(0);
        Id := Inner.GetInteger('id');
        Assert.AreEqual(1, Id, 'JsonArray.GetObject must return object with id=1');
    end;

    [Test]
    procedure JsonArray_GetOption_ReturnsInteger()
    var
        JArr: JsonArray;
    begin
        Initialize();
        JArr.ReadFrom('[3]');
        Assert.AreEqual(3, JArr.GetOption(0), 'JsonArray.GetOption must return 3');
    end;

    // ===== JsonValue remaining methods =====

    [Test]
    procedure JsonValue_AsChar_ReturnsChar()
    var
        JVal: JsonValue;
        Ch: Char;
    begin
        Initialize();
        JVal.SetValue('A');
        Ch := JVal.AsChar();
        Assert.AreEqual('A', Ch, 'JsonValue.AsChar must return ''A''');
    end;

    [Test]
    procedure JsonValue_AsOption_ReturnsInteger()
    var
        JVal: JsonValue;
    begin
        Initialize();
        JVal.SetValue(2);
        Assert.AreEqual(2, JVal.AsOption(), 'JsonValue.AsOption must return 2');
    end;

    [Test]
    procedure JsonValue_IsUndefined_AfterSetUndefined()
    var
        JVal: JsonValue;
    begin
        Initialize();
        JVal.SetValueToUndefined();
        Assert.IsTrue(JVal.IsUndefined(), 'JsonValue.IsUndefined must return true after SetValueToUndefined');
    end;

    [Test]
    procedure JsonValue_IsUndefined_WithValue_ReturnsFalse()
    var
        JVal: JsonValue;
    begin
        Initialize();
        JVal.SetValue(1);
        Assert.IsFalse(JVal.IsUndefined(), 'JsonValue.IsUndefined must return false after SetValue(1)');
    end;

    [Test]
    procedure JsonToken_SelectToken_ViaPath()
    var
        JObj: JsonObject;
        T: JsonToken;
        Selected: JsonToken;
        Result: Integer;
    begin
        Initialize();
        JObj.ReadFrom('{"a":{"b":99}}');
        T := JObj.AsToken();
        T.SelectToken('a.b', Selected);
        Result := Selected.AsValue().AsInteger();
        Assert.AreEqual(99, Result, 'JsonToken.SelectToken must find nested value 99');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
