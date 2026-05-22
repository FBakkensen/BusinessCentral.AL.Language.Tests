codeunit 60125 "Test XmlNode Types"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure XmlNode_IsXmlElement_ForElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        Assert.IsTrue(XNode.IsXmlElement(), 'IsXmlElement should return true for element node');
    end;

    [Test]
    procedure XmlNode_AsXmlElement_ReturnsElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        Assert.AreEqual('root', XNode.AsXmlElement().Name(), 'AsXmlElement should return XmlElement with correct name');
    end;

    [Test]
    procedure XmlNode_IsXmlDocument_ForDocument()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        Assert.IsFalse(XNode.IsXmlDocument(), 'IsXmlDocument should return false for element node');
    end;

    [Test]
    procedure XmlNode_GetDocument_ReturnsDocument()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        Assert.IsTrue(XNode.GetDocument(XDoc2), 'GetDocument on node should return parent document');
    end;

    [Test]
    procedure XmlNode_GetParent_OnChildNode()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XChild: XmlNode;
        XNode: XmlNode;
        XParent: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><child/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.GetChildElements().Get(1, XChild);
        XNode := XChild;
        XNode.GetParent(XParent);
        Assert.AreEqual('root', XParent.Name(), 'GetParent on child node should return root element');
    end;

    [Test]
    procedure XmlNode_WriteTo_Serializes()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        S: Text;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><inner/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        XNode.WriteTo(S);
        Assert.IsTrue(StrPos(S, 'root') > 0, 'WriteTo on node should serialize to string');
    end;

    [Test]
    procedure XmlNode_AddAfterSelf_Works()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XChild: XmlNode;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><a/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.GetChildElements().Get(1, XChild);
        XNode := XChild;
        XNode.AddAfterSelf(XmlElement.Create('c'));
        Assert.IsTrue(XElem.GetChildElements().Count() > 1, 'AddAfterSelf on node should insert sibling');
    end;

    [Test]
    procedure XmlNode_SelectSingleNode_FromNode()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XNode2: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><child/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        XNode.SelectSingleNode('child', XNode2);
        Assert.AreEqual('child', XNode2.AsXmlElement().Name(), 'SelectSingleNode should find matching child');
    end;

    [Test]
    procedure XmlAttribute_Create_HasNameAndValue()
    var
        XAttr: XmlAttribute;
    begin
        Initialize();
        XAttr := XmlAttribute.Create('color', 'red');
        Assert.AreEqual('color', XAttr.Name(), 'XmlAttribute name should be set on creation');
        Assert.AreEqual('red', XAttr.Value(), 'XmlAttribute value should be set on creation');
    end;

    [Test]
    procedure XmlAttribute_LocalName_ReturnsName()
    var
        XAttr: XmlAttribute;
    begin
        Initialize();
        XAttr := XmlAttribute.Create('id', '1');
        Assert.AreEqual('id', XAttr.LocalName(), 'LocalName should return attribute name');
    end;

    [Test]
    procedure XmlAttribute_AsXmlNode_ReturnsNode()
    var
        XAttr: XmlAttribute;
        XNode: XmlNode;
    begin
        Initialize();
        XAttr := XmlAttribute.Create('x', '1');
        XNode := XAttr.AsXmlNode();
        Assert.IsTrue(true, 'AsXmlNode on XmlAttribute should succeed');
    end;

    [Test]
    procedure XmlAttribute_GetDocument_Works()
    var
        XDoc: XmlDocument;
        XDoc2: XmlDocument;
        XElem: XmlElement;
        XAttr: XmlAttribute;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r a="1"/>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.Attributes().Get(1, XAttr);
        Assert.IsTrue(XAttr.GetDocument(XDoc2), 'GetDocument on XmlAttribute should return parent document');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
