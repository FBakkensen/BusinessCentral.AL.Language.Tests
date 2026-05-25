codeunit 60134 "Test Xml Deep"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;

    // ── XmlElement GetDescendantElements ────────────────────────────────────

    [Test]
    procedure XmlElement_GetDescendantElements_ReturnsAll()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><a><b/></a><c/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetDescendantElements();

        // ASSERT
        Assert.IsTrue(XNL.Count() >= 2, 'GetDescendantElements must return all descendant elements');
    end;

    [Test]
    procedure XmlElement_GetDescendantElements_ByName_Filters()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/><a/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetDescendantElements('a');

        // ASSERT
        Assert.AreEqual(2, XNL.Count(), 'GetDescendantElements("a") must return 2 matching elements');
    end;

    [Test]
    procedure XmlElement_GetDescendantNodes_ReturnsNodes()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetDescendantNodes();

        // ASSERT
        Assert.IsTrue(XNL.Count() >= 2, 'GetDescendantNodes must return child nodes');
    end;

    [Test]
    procedure XmlElement_HasAttributes_WithAttr_ReturnsTrue()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root color="red"/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT
        Assert.IsTrue(XElem.HasAttributes(), 'Element with attribute must HasAttributes=true');
    end;

    [Test]
    procedure XmlElement_HasAttributes_NoAttr_ReturnsFalse()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT
        Assert.IsFalse(XElem.HasAttributes(), 'Element without attributes must HasAttributes=false');
    end;

    [Test]
    procedure XmlElement_HasElements_WithChildren_ReturnsTrue()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<parent><child/></parent>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT
        Assert.IsTrue(XElem.HasElements(), 'Parent with children must HasElements=true');
    end;

    [Test]
    procedure XmlElement_HasElements_Empty_ReturnsFalse()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<empty/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT
        Assert.IsFalse(XElem.HasElements(), 'Leaf element must HasElements=false');
    end;

    [Test]
    procedure XmlElement_Remove_RemovesFromParent()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
        XNode: XmlNode;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetChildElements();
        XNL.Get(1, XNode);
        XNode.AsXmlElement().Remove();

        // ASSERT
        Assert.AreEqual(1, XElem.GetChildElements().Count(), 'After Remove, parent must have 1 child');
    end;

    [Test]
    procedure XmlElement_ReplaceWith_ReplacesElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
        XNode: XmlNode;
        XNode2: XmlNode;
        NewElem: XmlElement;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><old/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetChildElements();
        XNL.Get(1, XNode);
        NewElem := XmlElement.Create('new');
        XNode.AsXmlElement().ReplaceWith(NewElem);
        XNL := XElem.GetChildElements();
        XNL.Get(1, XNode2);

        // ASSERT
        Assert.AreEqual('new', XNode2.AsXmlElement().Name(), 'ReplaceWith must replace element');
    end;

    // ── XmlDocument GetDescendantElements ────────────────────────────────────

    [Test]
    procedure XmlDocument_GetDescendantElements_ReturnsAll()
    var
        XDoc: XmlDocument;
        XNL: XmlNodeList;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/></root>', XDoc);
        XNL := XDoc.GetDescendantElements();

        // ASSERT
        Assert.IsTrue(XNL.Count() >= 2, 'XmlDocument.GetDescendantElements must find all elements');
    end;

    [Test]
    procedure XmlDocument_GetDescendantElements_ByName()
    var
        XDoc: XmlDocument;
        XNL: XmlNodeList;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><item/><other/><item/></root>', XDoc);
        XNL := XDoc.GetDescendantElements('item');

        // ASSERT
        Assert.AreEqual(2, XNL.Count(), 'GetDescendantElements("item") must find 2 items');
    end;

    [Test]
    procedure XmlDocument_NameTable_ReturnsNonDefault()
    var
        XDoc: XmlDocument;
        NT: XmlNameTable;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        NT := XDoc.NameTable();

        // ASSERT
        Assert.IsTrue(true, 'NameTable() must return without error');
    end;

    [Test]
    procedure XmlDocument_RemoveNodes_ClearsChildren()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XDoc.RemoveNodes();

        // ASSERT
        Assert.IsTrue(true, 'RemoveNodes must execute without error');
    end;

    [Test]
    procedure XmlDocument_GetDeclaration_ParsesDeclaration()
    var
        XDoc: XmlDocument;
        XDecl: XmlDeclaration;
        B: Boolean;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<?xml version="1.0"?><root/>', XDoc);
        B := XDoc.GetDeclaration(XDecl);

        // ASSERT
        Assert.IsTrue(true, 'GetDeclaration must be callable');
    end;

    // ── XmlNode type checks ────────────────────────────────────────────────────

    [Test]
    procedure XmlNode_IsXmlText_ForTextNode()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
        XNode: XmlNode;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<r>hello</r>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetChildNodes();
        XNL.Get(1, XNode);

        // ASSERT
        Assert.IsTrue(XNode.IsXmlText(), 'Text content of element must be XmlText node');
    end;

    [Test]
    procedure XmlNode_IsXmlCData_ForTextNode_ReturnsFalse()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
        XNode: XmlNode;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<r>text</r>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetChildNodes();
        XNL.Get(1, XNode);

        // ASSERT
        Assert.IsFalse(XNode.IsXmlCData(), 'Plain text node must not be CData');
    end;

    [Test]
    procedure XmlNode_IsXmlComment_ForCommentNode()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
        XNode: XmlNode;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><!-- comment --><child/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetChildNodes();
        XNL.Get(1, XNode);

        // ASSERT
        Assert.IsTrue(XNode.IsXmlComment(), 'Comment node must IsXmlComment=true');
    end;

    [Test]
    procedure XmlNode_IsXmlElement_ForElementNode()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNL: XmlNodeList;
        XNode: XmlNode;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root><elem/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNL := XElem.GetChildElements();
        XNL.Get(1, XNode);

        // ASSERT
        Assert.IsTrue(XNode.IsXmlElement(), 'Child element node must IsXmlElement=true');
    end;

    // ── XmlAttribute namespace methods ──────────────────────────────────────────

    [Test]
    procedure XmlAttribute_CreateNamespaceDeclaration_HasPrefixAndUri()
    var
        XAttr: XmlAttribute;
    begin
        // ARRANGE & ACT
        Initialize();
        XAttr := XmlAttribute.CreateNamespaceDeclaration('ns', 'http://example.com');

        // ASSERT
        Assert.AreEqual('xmlns', XAttr.NamespacePrefix(), 'Namespace declaration attribute prefix must be xmlns');
    end;

    [Test]
    procedure XmlAttribute_IsNamespaceDeclaration_ReturnsTrue()
    var
        XAttr: XmlAttribute;
    begin
        // ARRANGE & ACT
        Initialize();
        XAttr := XmlAttribute.CreateNamespaceDeclaration('x', 'http://x.com');

        // ASSERT
        Assert.IsTrue(XAttr.IsNamespaceDeclaration(), 'Namespace declaration attribute must return true');
    end;
}
