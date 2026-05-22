codeunit 60124 "Test XmlElement Extended"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure XmlElement_AddAfterSelf_InsertsAfter()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNodeList: XmlNodeList;
        XChild: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><a/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.GetChildElements().Get(1, XChild);
        XChild.AddAfterSelf(XmlElement.Create('b'));
        Assert.AreEqual(2, XElem.GetChildElements().Count(), 'AddAfterSelf should insert sibling');
    end;

    [Test]
    procedure XmlElement_AddBeforeSelf_InsertsBefore()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XChild: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><b/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.GetChildElements().Get(1, XChild);
        XChild.AddBeforeSelf(XmlElement.Create('a'));
        Assert.AreEqual(2, XElem.GetChildElements().Count(), 'AddBeforeSelf should insert sibling');
    end;

    [Test]
    procedure XmlElement_AddFirst_InsertsFirst()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XChild: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><b/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.AddFirst(XmlElement.Create('a'));
        XElem.GetChildElements().Get(1, XNode);
        Assert.AreEqual('a', XNode.AsXmlElement().Name(), 'AddFirst should place element first');
    end;

    [Test]
    procedure XmlElement_AsXmlNode_IsXmlElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        Assert.IsTrue(XNode.IsXmlElement(), 'AsXmlNode should return XmlElement node');
    end;

    [Test]
    procedure XmlElement_GetChildElements_Count()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/><c/></root>', XDoc);
        XDoc.GetRoot(XElem);
        Assert.AreEqual(3, XElem.GetChildElements().Count(), 'GetChildElements should count all child elements');
    end;

    [Test]
    procedure XmlElement_GetChildElements_ByName()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/><a/></root>', XDoc);
        XDoc.GetRoot(XElem);
        Assert.AreEqual(2, XElem.GetChildElements('a').Count(), 'GetChildElements with name should filter matching elements');
    end;

    [Test]
    procedure XmlElement_GetChildNodes_Count()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/></root>', XDoc);
        XDoc.GetRoot(XElem);
        Assert.IsTrue(XElem.GetChildNodes().Count() >= 2, 'GetChildNodes should return all child nodes');
    end;

    [Test]
    procedure XmlElement_WriteTo_Serializes()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        S: Text;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r><c/></r>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.WriteTo(S);
        Assert.IsTrue(StrPos(S, 'c') > 0, 'WriteTo should serialize element to string');
    end;

    [Test]
    procedure XmlElement_GetDocument_ReturnsDoc()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        XElem: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r/>', XDoc);
        XDoc.GetRoot(XElem);
        Assert.IsTrue(XElem.GetDocument(XDoc2), 'GetDocument should return parent document');
    end;

    [Test]
    procedure XmlElement_GetParent_OnChild()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XChildNode: XmlNode;
        XParent: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><child/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.GetChildElements().Get(1, XChildNode);
        XChildNode.GetParent(XParent);
        Assert.AreEqual('root', XParent.Name(), 'GetParent should return parent element');
    end;

    [Test]
    procedure XmlElement_SelectNodes_ReturnsMultiple()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNodeList: XmlNodeList;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r><a/><a/><a/></r>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.SelectNodes('a', XNodeList);
        Assert.AreEqual(3, XNodeList.Count(), 'SelectNodes should return all matching elements');
    end;

    [Test]
    procedure XmlElement_SetAttribute_Multiple()
    var
        XElem: XmlElement;
        S: Text;
        XChild: XmlNode;
    begin
        Initialize();
        XElem := XmlElement.Create('e');
        XElem.SetAttribute('a', '1');
        XElem.SetAttribute('b', '2');
        XElem.WriteTo(S);
        Assert.IsTrue((StrPos(S, 'a') > 0) and (StrPos(S, 'b') > 0), 'SetAttribute should add multiple attributes');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
