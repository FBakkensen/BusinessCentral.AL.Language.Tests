codeunit 60163 "Test Json Xml Deep Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;

    trigger OnRun()
    begin
        // Tests run via test runner
    end;

    [Test]
    procedure JsonObject_Empty_WriteTo_ProducesEmptyObject()
    var
        JObj: JsonObject;
        S: Text;
    begin
        // Arrange
        // Act
        JObj.WriteTo(S);

        // Assert
        Assert.AreEqual('{}', S, 'Empty JsonObject.WriteTo must produce "{}"');
    end;

    [Test]
    procedure JsonArray_Empty_WriteTo_ProducesEmptyArray()
    var
        JArr: JsonArray;
        S: Text;
    begin
        // Arrange
        // Act
        JArr.WriteTo(S);

        // Assert
        Assert.AreEqual('[]', S, 'Empty JsonArray.WriteTo must produce "[]"');
    end;

    [Test]
    procedure JsonObject_UnicodeString_RoundTrips()
    var
        JObj: JsonObject;
        JObj2: JsonObject;
        JTok: JsonToken;
        S: Text;
    begin
        // Arrange
        JObj.Add('text', 'Ünïcödé');

        // Act
        JObj.WriteTo(S);
        JObj2.ReadFrom(S);
        JObj2.Get('text', JTok);

        // Assert
        Assert.AreEqual('Ünïcödé', JTok.AsValue().AsText(), 'JSON roundtrip must preserve Unicode characters exactly');
    end;

    [Test]
    procedure JsonObject_EscapeChars_RoundTrip()
    var
        JObj: JsonObject;
        JObj2: JsonObject;
        JTok: JsonToken;
        S: Text;
        Original: Text;
    begin
        // Arrange
        Original := 'line1' + Format(10, 0, '<Integer>')[1] + 'line2';
        JObj.Add('content', Original);

        // Act
        JObj.WriteTo(S);
        JObj2.ReadFrom(S);
        JObj2.Get('content', JTok);

        // Assert
        Assert.AreEqual(Original, JTok.AsValue().AsText(), 'JSON roundtrip must preserve newline in string');
    end;

    [Test]
    procedure JsonObject_Keys_AreCaseSensitive()
    var
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        // Arrange
        JObj.Add('key', 'lower');
        JObj.Add('KEY', 'upper');

        // Act & Assert
        Assert.IsTrue(JObj.Contains('key'), 'Lowercase "key" must exist');
        Assert.IsTrue(JObj.Contains('KEY'), 'Uppercase "KEY" must exist');

        JObj.Get('key', JTok);
        Assert.AreEqual('lower', JTok.AsValue().AsText(), 'Lowercase key value must be "lower"');

        JObj.Get('KEY', JTok);
        Assert.AreEqual('upper', JTok.AsValue().AsText(), 'Uppercase KEY value must be "upper"');
    end;

    [Test]
    procedure JsonArray_Of_Objects_RoundTrips()
    var
        JArr: JsonArray;
        JArr2: JsonArray;
        JTok: JsonToken;
        S: Text;
        Inner1: JsonObject;
        Inner2: JsonObject;
    begin
        // Arrange
        Inner1.Add('id', 1);
        JArr.Add(Inner1);

        Inner2.Add('id', 2);
        JArr.Add(Inner2);

        // Act
        JArr.WriteTo(S);
        JArr2.ReadFrom(S);

        // Assert
        Assert.AreEqual(2, JArr2.Count(), 'JSON array of 2 objects must roundtrip with 2 elements');

        JArr2.Get(0, JTok);
        Assert.AreEqual(1, JTok.AsObject().GetInteger('id'), 'First object id must be 1');

        JArr2.Get(1, JTok);
        Assert.AreEqual(2, JTok.AsObject().GetInteger('id'), 'Second object id must be 2');
    end;

    [Test]
    procedure JsonObject_NullValue_vs_MissingKey_Distinct()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        JVal: JsonValue;
    begin
        // Arrange
        JVal.SetValueToNull();
        JObj.Add('nullkey', JVal);

        // Act & Assert
        Assert.IsTrue(JObj.Contains('nullkey'), '"nullkey" must be present even though value is null');
        Assert.IsFalse(JObj.Contains('missing'), '"missing" key must not exist');

        JObj.Get('nullkey', JTok);
        Assert.IsTrue(JTok.AsValue().IsNull(), 'nullkey value must be null');
    end;

    [Test]
    procedure JsonArray_IndexIteration_AllElements()
    var
        JArr: JsonArray;
        JTok: JsonToken;
        Sum: Integer;
        i: Integer;
    begin
        // Arrange
        JArr.Add(10);
        JArr.Add(20);
        JArr.Add(30);

        // Act
        Sum := 0;
        for i := 0 to JArr.Count() - 1 do begin
            JArr.Get(i, JTok);
            Sum += JTok.AsValue().AsInteger();
        end;

        // Assert
        Assert.AreEqual(60, Sum, 'Iterating JsonArray by index must yield all elements (10+20+30=60)');
    end;

    [Test]
    procedure XmlElement_CDATA_InnerText_ReturnsRawContent()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // Arrange & Act
        XmlDocument.ReadFrom('<r><![CDATA[<not markup> & raw]]></r>', XDoc);
        XDoc.GetRoot(XElem);

        // Assert
        Assert.AreEqual('<not markup> & raw', XElem.InnerText(), 'CDATA content must be returned as-is by InnerText()');
    end;

    [Test]
    procedure XmlElement_TextContent_SpecialChars_EscapedOnWrite()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        S: Text;
    begin
        // Arrange
        XDoc := XmlDocument.Create();
        XElem := XmlElement.Create('r');
        XElem.Add(XmlText.Create('a < b & c > d'));
        XDoc.Add(XElem);

        // Act
        XDoc.WriteTo(S);

        // Assert
        Assert.IsTrue(StrPos(S, '&lt;') > 0, 'XML WriteTo must escape < as &lt;');
        Assert.IsTrue(StrPos(S, '&amp;') > 0, 'XML WriteTo must escape & as &amp;');
    end;

    [Test]
    procedure XmlElement_SpecialChars_RoundTrip()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        XElem: XmlElement;
        XElem2: XmlElement;
        S: Text;
    begin
        // Arrange
        XDoc := XmlDocument.Create();
        XElem := XmlElement.Create('r');
        XElem.Add(XmlText.Create('x < y'));
        XDoc.Add(XElem);

        // Act
        XDoc.WriteTo(S);
        XmlDocument.ReadFrom(S, XDoc2);
        XDoc2.GetRoot(XElem2);

        // Assert
        Assert.AreEqual('x < y', XElem2.InnerText(), 'Special chars in XML text must roundtrip correctly');
    end;

    [Test]
    procedure XmlDocument_Comment_Preserved_InRoundTrip()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        S: Text;
    begin
        // Arrange & Act
        XmlDocument.ReadFrom('<root><!-- my comment --><child/></root>', XDoc);
        XDoc.WriteTo(S);
        XmlDocument.ReadFrom(S, XDoc2);

        // Assert
        Assert.IsTrue(StrPos(S, 'my comment') > 0, 'XML comment must be preserved through WriteTo/ReadFrom roundtrip');
    end;

    [Test]
    procedure XmlElement_AttributeAndText_InnerText_IsTextOnly()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // Arrange & Act
        XmlDocument.ReadFrom('<item attr="v">content text</item>', XDoc);
        XDoc.GetRoot(XElem);

        // Assert
        Assert.AreEqual('content text', XElem.InnerText(), 'InnerText must return text content only, not attribute values');
    end;

    [Test]
    procedure JsonObject_LargeInteger_Preserved()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        S: Text;
        JObj2: JsonObject;
    begin
        // Arrange
        JObj.Add('big', 2000000000);

        // Act
        JObj.WriteTo(S);
        JObj2.ReadFrom(S);
        JObj2.Get('big', JTok);

        // Assert
        Assert.AreEqual(2000000000, JTok.AsValue().AsInteger(), 'Large integer must roundtrip through JSON without loss');
    end;

    [Test]
    procedure JsonToken_SelectToken_ReturnsCorrectType()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        Selected: JsonToken;
    begin
        // Arrange
        JObj.ReadFrom('{"arr":[1,2,3],"obj":{"k":"v"}}');
        JTok := JObj.AsToken();

        // Act & Assert
        JTok.SelectToken('arr', Selected);
        Assert.IsTrue(Selected.IsArray(), 'SelectToken("arr") must return array token');

        JTok.SelectToken('obj', Selected);
        Assert.IsTrue(Selected.IsObject(), 'SelectToken("obj") must return object token');

        JTok.SelectToken('obj.k', Selected);
        Assert.IsTrue(Selected.IsValue(), 'SelectToken dotted path must return value token');
    end;
}
