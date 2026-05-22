codeunit 60106 "Test XmlDocument"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;

    [Test]
    procedure XmlDocument_ReadFrom_ParsesValidXml()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<r><c>hello</c></r>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - FAILS if XElem.Name() returns '' or anything except 'r'
        Assert.AreEqual('r', XElem.Name(), 'Root element name must be "r"');
    end;

    [Test]
    procedure XmlDocument_GetRoot_ReturnsRootElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - FAILS if XElem.Name() is not 'root'
        Assert.AreEqual('root', XElem.Name(), 'GetRoot must return element named "root"');
    end;

    [Test]
    procedure XmlDocument_WriteTo_SerializesXml()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        S: Text;
    begin
        // ARRANGE
        XDoc := XmlDocument.Create();
        XElem := XmlElement.Create('test');
        XDoc.Add(XElem);

        // ACT
        XDoc.WriteTo(S);

        // ASSERT - FAILS if S does not contain '<test'
        Assert.IsTrue(StrPos(S, '<test') > 0, 'WriteTo must serialize element to string containing "<test"');
    end;

    [Test]
    procedure XmlDocument_ReadFrom_Returns_Success()
    var
        XDoc: XmlDocument;
        Ok: Boolean;
    begin
        // ACT
        Ok := XmlDocument.ReadFrom('<x/>', XDoc);

        // ASSERT - FAILS if Ok is false (indicating parse failure)
        Assert.IsTrue(Ok, 'ReadFrom valid XML must return true');
    end;

    [Test]
    procedure XmlDocument_ReadFrom_InvalidXml_ReturnsFalse()
    var
        XDoc: XmlDocument;
        Ok: Boolean;
    begin
        // ACT
        Ok := XmlDocument.ReadFrom('not xml', XDoc);

        // ASSERT - FAILS if Ok is true (invalid XML should fail to parse)
        Assert.IsFalse(Ok, 'ReadFrom invalid XML must return false');
    end;

    [Test]
    procedure XmlDocument_SelectSingleNode_FindsNode()
    var
        XDoc: XmlDocument;
        XN: XmlNode;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<root><child id="1"/></root>', XDoc);
        XDoc.SelectSingleNode('//child', XN);
        XElem := XN.AsXmlElement();

        // ASSERT - FAILS if XElem.Name() is not 'child'
        Assert.AreEqual('child', XElem.Name(), 'SelectSingleNode must find <child> element');
    end;

    [Test]
    procedure XmlDocument_Root_HasInnerContent()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<root><c>text</c></root>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - FAILS if InnerText is empty (root has <c> child with text)
        Assert.IsTrue(XElem.InnerText() <> '', 'Root element must have inner content');
    end;

    [Test]
    procedure XmlDocument_WriteTo_ContainsRoot()
    var
        XDoc: XmlDocument;
        S: Text;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<hello/>', XDoc);
        XDoc.WriteTo(S);

        // ASSERT - FAILS if S does not contain 'hello'
        Assert.IsTrue(StrPos(S, 'hello') > 0, 'WriteTo must contain root element name');
    end;
}
