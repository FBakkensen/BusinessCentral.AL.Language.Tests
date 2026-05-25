// Roundtrip Contract Tests: JSON, XML, Stream, Type Coercion
// Fixtures used: ALT Blob (60008)
// BC Runtime: 16.1, Target: Cloud
// CONTRACT tests — each proves a specific invariant that must hold.

codeunit 60151 "Test Roundtrip Contracts"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── JSON ROUNDTRIP CONTRACTS ─────────────────────────────────────────────────

    [Test]
    procedure JsonObject_WriteTo_ReadFrom_PreservesText()
    var
        JObj: JsonObject;
        JObj2: JsonObject;
        JTok: JsonToken;
        S: Text;
    begin
        // Arrange
        Initialize();
        JObj.Add('name', 'Alice');
        JObj.Add('city', 'Berlin');

        // Act
        JObj.WriteTo(S);
        JObj2.ReadFrom(S);

        // Assert
        JObj2.Get('name', JTok);
        Assert.AreEqual('Alice', JTok.AsValue().AsText(), 'Roundtrip must preserve string value');
        JObj2.Get('city', JTok);
        Assert.AreEqual('Berlin', JTok.AsValue().AsText(), 'Roundtrip must preserve second string');
    end;

    [Test]
    procedure JsonObject_WriteTo_ReadFrom_PreservesInteger()
    var
        JObj: JsonObject;
        JObj2: JsonObject;
        JTok: JsonToken;
        S: Text;
    begin
        // Arrange
        Initialize();
        JObj.Add('count', 42);

        // Act
        JObj.WriteTo(S);
        JObj2.ReadFrom(S);

        // Assert
        JObj2.Get('count', JTok);
        Assert.AreEqual(42, JTok.AsValue().AsInteger(), 'Roundtrip must preserve integer');
    end;

    [Test]
    procedure JsonObject_WriteTo_ReadFrom_PreservesBoolean()
    var
        JObj: JsonObject;
        JObj2: JsonObject;
        JTok: JsonToken;
        S: Text;
    begin
        // Arrange
        Initialize();
        JObj.Add('active', true);
        JObj.Add('deleted', false);

        // Act
        JObj.WriteTo(S);
        JObj2.ReadFrom(S);

        // Assert
        JObj2.Get('active', JTok);
        Assert.IsTrue(JTok.AsValue().AsBoolean(), 'Roundtrip must preserve true');
        JObj2.Get('deleted', JTok);
        Assert.IsFalse(JTok.AsValue().AsBoolean(), 'Roundtrip must preserve false');
    end;

    [Test]
    procedure JsonObject_WriteTo_ReadFrom_PreservesNull()
    var
        JObj: JsonObject;
        JObj2: JsonObject;
        JTok: JsonToken;
        JVal: JsonValue;
        S: Text;
    begin
        // Arrange
        Initialize();
        JVal.SetValueToNull();
        JObj.Add('nullfield', JVal);

        // Act
        JObj.WriteTo(S);
        JObj2.ReadFrom(S);

        // Assert
        JObj2.Get('nullfield', JTok);
        Assert.IsTrue(JTok.AsValue().IsNull(), 'Roundtrip must preserve null');
    end;

    [Test]
    procedure JsonArray_WriteTo_ReadFrom_PreservesOrder()
    var
        JArr: JsonArray;
        JArr2: JsonArray;
        JTok: JsonToken;
        S: Text;
    begin
        // Arrange
        Initialize();
        JArr.Add(10);
        JArr.Add(20);
        JArr.Add(30);

        // Act
        JArr.WriteTo(S);
        JArr2.ReadFrom(S);

        // Assert
        JArr2.Get(0, JTok);
        Assert.AreEqual(10, JTok.AsValue().AsInteger(), 'First element must be preserved');
        JArr2.Get(2, JTok);
        Assert.AreEqual(30, JTok.AsValue().AsInteger(), 'Third element must be preserved');
    end;

    [Test]
    procedure JsonObject_Nested_Object_Roundtrip()
    var
        Inner: JsonObject;
        JObj3: JsonObject;
        JObj4: JsonObject;
        InnerObj: JsonObject;
        JTok: JsonToken;
        InnerJTok: JsonToken;
        S: Text;
    begin
        // Arrange
        Initialize();
        Inner.Add('val', 99);
        JObj3.Add('inner', Inner);

        // Act
        JObj3.WriteTo(S);
        JObj4.ReadFrom(S);

        // Assert
        JObj4.Get('inner', JTok);
        InnerObj := JTok.AsObject();
        InnerObj.Get('val', InnerJTok);
        Assert.AreEqual(99, InnerJTok.AsValue().AsInteger(), 'Nested object must roundtrip correctly');
    end;

    [Test]
    procedure JsonObject_Contains_ReturnsFalse_AfterRemove()
    var
        JObj: JsonObject;
        S: Text;
    begin
        // Arrange
        Initialize();
        JObj.Add('key', 1);

        // Act
        JObj.Remove('key');

        // Assert
        Assert.IsFalse(JObj.Contains('key'), 'After Remove, Contains must return false');
        JObj.WriteTo(S);
        Assert.IsFalse(S.Contains('"key"'), 'Serialized JSON must not contain removed key');
    end;

    [Test]
    procedure JsonToken_SelectToken_NestedPath()
    var
        JObj: JsonObject;
        JTok: JsonToken;
        Selected: JsonToken;
    begin
        // Arrange
        Initialize();
        JObj.ReadFrom('{"level1":{"level2":{"val":42}}}');

        // Act
        JTok := JObj.AsToken();
        JTok.SelectToken('level1.level2.val', Selected);

        // Assert
        Assert.AreEqual(42, Selected.AsValue().AsInteger(), 'SelectToken with dotted path must navigate nested objects');
    end;

    // ── XML ROUNDTRIP CONTRACTS ──────────────────────────────────────────────────

    [Test]
    procedure XmlDocument_WriteTo_ReadFrom_PreservesRoot()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        XElem: XmlElement;
        S: Text;
    begin
        // Arrange
        Initialize();
        XmlDocument.ReadFrom('<root><child1/><child2/></root>', XDoc);

        // Act
        XDoc.WriteTo(S);
        XmlDocument.ReadFrom(S, XDoc2);

        // Assert
        XDoc2.GetRoot(XElem);
        Assert.AreEqual('root', XElem.Name(), 'Roundtrip must preserve root element name');
    end;

    [Test]
    procedure XmlDocument_WriteTo_ReadFrom_PreservesInnerText()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        XElem: XmlElement;
        S: Text;
    begin
        // Arrange
        Initialize();
        XmlDocument.ReadFrom('<root>HelloWorld</root>', XDoc);

        // Act
        XDoc.WriteTo(S);
        XmlDocument.ReadFrom(S, XDoc2);

        // Assert
        XDoc2.GetRoot(XElem);
        Assert.AreEqual('HelloWorld', XElem.InnerText(), 'Roundtrip must preserve inner text');
    end;

    [Test]
    procedure XmlDocument_WriteTo_ReadFrom_PreservesAttribute()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        XElem: XmlElement;
        S: Text;
    begin
        // Arrange
        Initialize();
        XmlDocument.ReadFrom('<item color="red" size="large"/>', XDoc);

        // Act
        XDoc.WriteTo(S);
        XmlDocument.ReadFrom(S, XDoc2);

        // Assert
        XDoc2.GetRoot(XElem);
        Assert.IsTrue(XElem.HasAttributes(), 'Roundtrip must preserve attributes');
        Assert.IsTrue(S.Contains('color'), 'Serialized XML must contain attribute name');
    end;

    [Test]
    procedure XmlElement_Add_Then_GetChildElements_Roundtrip()
    var
        XRoot: XmlElement;
        XChild1: XmlElement;
        XChild2: XmlElement;
        XNL: XmlNodeList;
        XN: XmlNode;
    begin
        // Arrange
        Initialize();
        XRoot := XmlElement.Create('parent');
        XChild1 := XmlElement.Create('first');
        XChild2 := XmlElement.Create('second');

        // Act
        XRoot.Add(XChild1);
        XRoot.Add(XChild2);
        XNL := XRoot.GetChildElements();

        // Assert
        Assert.AreEqual(2, XNL.Count(), 'After adding 2 children, GetChildElements must return 2');
        XNL.Get(1, XN);
        Assert.AreEqual('first', XN.AsXmlElement().Name(), 'First child must be preserved');
        XNL.Get(2, XN);
        Assert.AreEqual('second', XN.AsXmlElement().Name(), 'Second child must be preserved');
    end;

    // ── STREAM ROUNDTRIP CONTRACTS ───────────────────────────────────────────────

    [Test]
    procedure OutStream_WriteText_InStream_ReadText_Preserves()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadBack: Text;
    begin
        // Arrange
        Initialize();
        BlobRec.Code := 'RT1';
        BlobRec.Data.CreateOutStream(OutStr);

        // Act
        OutStr.WriteText('Roundtrip test string 12345');
        BlobRec.Insert();
        BlobRec.Get('RT1');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(ReadBack);

        // Assert
        // WriteText adds CR/LF, ReadText reads until CR/LF, so content should match
        Assert.AreEqual('Roundtrip test string 12345', ReadBack, 'Stream write/read must preserve exact content');
    end;

    [Test]
    procedure OutStream_WriteInt_InStream_ReadInt_Preserves()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadInt: Integer;
    begin
        // Arrange
        Initialize();
        BlobRec.Code := 'RT2';
        BlobRec.Data.CreateOutStream(OutStr);

        // Act
        OutStr.Write(12345);
        BlobRec.Insert();
        BlobRec.Get('RT2');
        BlobRec.Data.CreateInStream(InStr);
        InStr.Read(ReadInt);

        // Assert
        Assert.AreEqual(12345, ReadInt, 'Binary integer write/read must preserve value');
    end;

    [Test]
    procedure InStream_ResetPosition_AllowsReread()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        First: Text;
        Second: Text;
    begin
        // Arrange
        Initialize();
        BlobRec.Code := 'RT3';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('RereadMe');
        BlobRec.Insert();

        // Act
        BlobRec.Get('RT3');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(First);
        InStr.ResetPosition();
        InStr.ReadText(Second);

        // Assert
        Assert.AreEqual(First, Second, 'After ResetPosition, re-reading must produce identical content');
    end;

    // ── TYPE COERCION CONTRACTS ──────────────────────────────────────────────────

    [Test]
    procedure Format_Evaluate_IntegerRoundtrip()
    var
        I: Integer;
        I2: Integer;
        S: Text;
    begin
        // Arrange
        Initialize();
        I := 12345;

        // Act
        S := Format(I);
        Evaluate(I2, S);

        // Assert
        Assert.AreEqual(I, I2, 'Format then Evaluate must roundtrip Integer exactly');
    end;

    [Test]
    procedure Format_Evaluate_DecimalRoundtrip()
    var
        D: Decimal;
        D2: Decimal;
        S: Text;
    begin
        // Arrange
        Initialize();
        D := 3.14159;

        // Act
        S := Format(D);
        Evaluate(D2, S);

        // Assert
        Assert.IsTrue(Abs(D - D2) < 0.001, 'Format then Evaluate must roundtrip Decimal approximately');
    end;

    [Test]
    procedure Format_Evaluate_DateRoundtrip()
    var
        Dt: Date;
        Dt2: Date;
        S: Text;
    begin
        // Arrange
        Initialize();
        Dt := 20240315D;

        // Act
        S := Format(Dt);
        Evaluate(Dt2, S);

        // Assert
        Assert.AreEqual(Dt, Dt2, 'Format then Evaluate must roundtrip Date exactly');
    end;

    [Test]
    procedure Evaluate_InvalidText_ReturnsFalse()
    var
        I: Integer;
        B: Boolean;
    begin
        // Arrange
        Initialize();
        I := 99;

        // Act
        B := Evaluate(I, 'notanumber');

        // Assert
        Assert.IsFalse(B, 'Evaluate with invalid input must return false');
    end;

    [Test]
    procedure CopyStr_BeyondEnd_ReturnsEmpty()
    var
        S: Text;
    begin
        // Arrange
        Initialize();
        S := 'hello';

        // Act & Assert
        Assert.AreEqual('', CopyStr(S, 10), 'CopyStr starting beyond string length must return empty string');
    end;

    // ── HELPERS ──────────────────────────────────────────────────────────────────

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
