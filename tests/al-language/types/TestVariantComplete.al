// Scope: in-scope

codeunit 60139 "Test Variant Complete"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Variant.IsJsonArray / IsJsonObject / IsDictionary / IsList ────────────

    [Test]
    procedure Variant_IsJsonArray_ReturnsTrue()
    var
        V: Variant;
        JArr: JsonArray;
    begin
        Initialize();
        V := JArr;
        Assert.IsTrue(V.IsJsonArray(), 'Variant must report IsJsonArray=true after assigning empty JsonArray');
    end;

    [Test]
    procedure Variant_IsJsonObject_ReturnsTrue()
    var
        V: Variant;
        JObj: JsonObject;
    begin
        Initialize();
        V := JObj;
        Assert.IsTrue(V.IsJsonObject(), 'Variant must report IsJsonObject=true after assigning empty JsonObject');
    end;

    [Test]
    procedure Variant_IsJsonToken_ReturnsTrue()
    var
        V: Variant;
        JObj: JsonObject;
        JTok: JsonToken;
    begin
        Initialize();
        JObj.Add('k', 'v');
        JObj.Get('k', JTok);
        V := JTok;
        Assert.IsTrue(V.IsJsonToken(), 'Variant must report IsJsonToken=true after assigning JsonToken');
    end;

    [Test]
    procedure Variant_IsJsonValue_ReturnsTrue()
    var
        V: Variant;
        JVal: JsonValue;
    begin
        Initialize();
        JVal.SetValue(42);
        V := JVal;
        Assert.IsTrue(V.IsJsonValue(), 'Variant must report IsJsonValue=true after assigning JsonValue');
    end;

    [Test]
    procedure Variant_IsDictionary_ReturnsTrue()
    var
        V: Variant;
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        V := D;
        Assert.IsTrue(V.IsDictionary(), 'Variant must report IsDictionary=true after assigning Dictionary');
    end;

    [Test]
    procedure Variant_IsList_ReturnsTrue()
    var
        V: Variant;
        L: List of [Integer];
    begin
        Initialize();
        V := L;
        Assert.IsTrue(V.IsList(), 'Variant must report IsList=true after assigning List');
    end;

    [Test]
    procedure Variant_IsXmlElement_ReturnsTrue()
    var
        V: Variant;
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r/>', XDoc);
        XDoc.GetRoot(XElem);
        V := XElem;
        Assert.IsTrue(V.IsXmlElement(), 'Variant must report IsXmlElement=true after assigning XmlElement');
    end;

    [Test]
    procedure Variant_IsXmlNode_ReturnsTrue()
    var
        V: Variant;
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        V := XNode;
        Assert.IsTrue(V.IsXmlNode(), 'Variant must report IsXmlNode=true after assigning XmlNode');
    end;

    // ── Variant type coercion (negation cases) ────────────────────────────────

    [Test]
    procedure Variant_IsJsonArray_ReturnsFalse_ForInteger()
    var
        V: Variant;
    begin
        Initialize();
        V := 42;
        Assert.IsFalse(V.IsJsonArray(), 'Variant.IsJsonArray must return false for Integer');
    end;

    [Test]
    procedure Variant_IsJsonObject_ReturnsFalse_ForText()
    var
        V: Variant;
    begin
        Initialize();
        V := 'hello';
        Assert.IsFalse(V.IsJsonObject(), 'Variant.IsJsonObject must return false for Text');
    end;

    [Test]
    procedure Variant_IsDictionary_ReturnsFalse_ForList()
    var
        V: Variant;
        L: List of [Text];
    begin
        Initialize();
        V := L;
        Assert.IsFalse(V.IsDictionary(), 'Variant.IsDictionary must return false for List');
    end;

    [Test]
    procedure Variant_IsList_ReturnsFalse_ForDictionary()
    var
        V: Variant;
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        V := D;
        Assert.IsFalse(V.IsList(), 'Variant.IsList must return false for Dictionary');
    end;

            local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
