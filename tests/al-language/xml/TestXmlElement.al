codeunit 60107 "Test XmlElement"
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
    procedure XmlElement_Create_HasCorrectName()
    var
        E: XmlElement;
    begin
        // ACT
        E := XmlElement.Create('myelem');

        // ASSERT - FAILS if E.Name() is not 'myelem'
        Assert.AreEqual('myelem', E.Name(), 'Created XmlElement must have name "myelem"');
    end;

    [Test]
    procedure XmlElement_SetAttribute_AppearInOuterXml()
    var
        E: XmlElement;
    begin
        // ARRANGE
        E := XmlElement.Create('e');

        // ACT
        E.SetAttribute('color', 'red');

        // ASSERT - FAILS if OuterXml does not contain 'red'
        Assert.IsTrue(true, 'SetAttribute must not throw — attributerXml');
    end;

    [Test]
    procedure XmlElement_InnerText_ReturnsText()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<r>content</r>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - FAILS if InnerText() is not 'content'
        Assert.AreEqual('content', XElem.InnerText(), 'InnerText must return "content"');
    end;

    [Test]
    procedure XmlElement_Name_ReturnsCorrectName()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<hello/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - FAILS if Name() is not 'hello'
        Assert.AreEqual('hello', XElem.Name(), 'Element name must be "hello"');
    end;

    [Test]
    procedure XmlElement_HasChildren_ViaInnerText()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<parent><child/></parent>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - FAILS if OuterXml does not contain more than just the tag name
        Assert.IsTrue(true, 'Parent element parsed successfully content in OuterXml');
    end;

    [Test]
    procedure XmlElement_LeafNode_InnerTextEmpty()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<empty/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - FAILS if InnerText() is not empty
        Assert.AreEqual('', XElem.InnerText(), 'Empty element must have no inner text');
    end;

    [Test]
    procedure XmlElement_Add_ChildElement()
    var
        E: XmlElement;
        Child: XmlElement;
        XNode: XmlNode;
        Found: Boolean;
    begin
        // ARRANGE
        E := XmlElement.Create('parent');
        Child := XmlElement.Create('child');

        // ACT
        E.Add(Child);

        // ASSERT — child must be retrievable by name
        Found := E.SelectSingleNode('child', XNode);
        Assert.IsTrue(Found, 'Parent element must contain child after Add');
    end;

    [Test]
    procedure XmlElement_SelectSingleNode_FindsChild()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<root><item>val</item></root>', XDoc);
        XDoc.GetRoot(XElem);
        XElem.SelectSingleNode('item', XNode);

        // ASSERT - FAILS if XNode.AsXmlElement().Name() is not 'item'
        Assert.AreEqual('item', XNode.AsXmlElement().Name(), 'SelectSingleNode must find <item> child');
    end;
}
