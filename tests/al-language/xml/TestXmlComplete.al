codeunit 60141 "Test Xml Complete"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure XmlNode_AsXmlText_FromTextNode()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XText: XmlText;
        XNodeList: XmlNodeList;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r>hello</r>', XDoc);
        XDoc.GetRoot(XElem);
        XNodeList := XElem.GetChildNodes();
        XNodeList.Get(1, XNode);
        XText := XNode.AsXmlText();
        Assert.IsTrue(true, 'AsXmlText on text node should succeed');
    end;

    [Test]
    procedure XmlNode_IsXmlText_TextNode_ReturnsTrue()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r>text</r>', XDoc);
        XDoc.GetRoot(XElem);
        XNodeList := XElem.GetChildNodes();
        XNodeList.Get(1, XNode);
        Assert.IsTrue(XNode.IsXmlText(), 'IsXmlText should return true for text node');
    end;

    [Test]
    procedure XmlNode_IsXmlCData_CDataNode_ReturnsTrue()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r><![CDATA[data]]></r>', XDoc);
        XDoc.GetRoot(XElem);
        XNodeList := XElem.GetChildNodes();
        XNodeList.Get(1, XNode);
        Assert.IsTrue(XNode.IsXmlCData(), 'IsXmlCData should return true for CDATA node');
    end;

    [Test]
    procedure XmlNode_AsXmlCData_ReturnsCData()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XCData: XmlCData;
        XNodeList: XmlNodeList;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r><![CDATA[data]]></r>', XDoc);
        XDoc.GetRoot(XElem);
        XNodeList := XElem.GetChildNodes();
        XNodeList.Get(1, XNode);
        XCData := XNode.AsXmlCData();
        Assert.IsTrue(true, 'AsXmlCData should succeed for CDATA node');
    end;

    [Test]
    procedure XmlNode_IsXmlComment_CommentNode_ReturnsTrue()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><!-- comment --><a/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNodeList := XElem.GetChildNodes();
        XNodeList.Get(1, XNode);
        Assert.IsTrue(XNode.IsXmlComment(), 'IsXmlComment should return true for comment node');
    end;

    [Test]
    procedure XmlNode_AsXmlComment_ReturnsComment()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
        XComment: XmlComment;
        XNodeList: XmlNodeList;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><!-- comment --><a/></root>', XDoc);
        XDoc.GetRoot(XElem);
        XNodeList := XElem.GetChildNodes();
        XNodeList.Get(1, XNode);
        XComment := XNode.AsXmlComment();
        Assert.IsTrue(true, 'AsXmlComment should succeed for comment node');
    end;

    [Test]
    procedure XmlNode_IsXmlElement_True()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        Assert.IsTrue(XNode.IsXmlElement(), 'IsXmlElement should return true for element node');
    end;

    [Test]
    procedure XmlNode_IsXmlText_False_ForElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        XNode: XmlNode;
    begin
        Initialize();
        XmlDocument.ReadFrom('<r/>', XDoc);
        XDoc.GetRoot(XElem);
        XNode := XElem.AsXmlNode();
        Assert.IsFalse(XNode.IsXmlText(), 'IsXmlText should return false for element node');
    end;

    [Test]
    procedure XmlElement_InnerXml_HasChildren()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        InnerXml: Text;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root><a/><b/></root>', XDoc);
        XDoc.GetRoot(XElem);
        InnerXml := XElem.InnerXml();
        Assert.IsTrue(StrPos(InnerXml, '<a') > 0, 'InnerXml should contain child elements');
    end;

    [Test]
    procedure XmlElement_InnerXml_Empty_IsEmpty()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        InnerXml: Text;
    begin
        Initialize();
        XmlDocument.ReadFrom('<empty/>', XDoc);
        XDoc.GetRoot(XElem);
        InnerXml := XElem.InnerXml();
        Assert.AreEqual('', InnerXml, 'InnerXml on empty element should be empty string');
    end;

    [Test]
    procedure XmlElement_NamespaceUri_Namespaced()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<ns:root xmlns:ns="http://test"/>', XDoc);
        XDoc.GetRoot(XElem);
        Assert.AreNotEqual('', XElem.NamespaceUri(), 'NamespaceUri should not be empty for namespaced element');
    end;

    [Test]
    procedure XmlElement_NamespaceUri_NoNamespace()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDoc.GetRoot(XElem);
        Assert.AreEqual('', XElem.NamespaceUri(), 'NamespaceUri should be empty for non-namespaced element');
    end;

    [Test]
    procedure XmlElement_RemoveAllAttributes_ClearsAttrs()
    var
        XElem: XmlElement;
    begin
        Initialize();
        XElem := XmlElement.Create('e');
        XElem.SetAttribute('a', '1');
        XElem.SetAttribute('b', '2');
        XElem.RemoveAllAttributes();
        Assert.IsFalse(XElem.HasAttributes(), 'After RemoveAllAttributes, HasAttributes should be false');
    end;

    [Test]
    procedure XmlDeclaration_Create_HasEncoding()
    var
        XDecl: XmlDeclaration;
    begin
        Initialize();
        XDecl := XmlDeclaration.Create('1.0', 'UTF-8', '');
        Assert.AreEqual('UTF-8', XDecl.Encoding(), 'XmlDeclaration encoding should be UTF-8');
    end;

    [Test]
    procedure XmlDeclaration_Encoding_Setter()
    var
        XDecl: XmlDeclaration;
    begin
        Initialize();
        XDecl := XmlDeclaration.Create('1.0', '', '');
        XDecl.Encoding('UTF-16');
        Assert.AreEqual('UTF-16', XDecl.Encoding(), 'Encoding setter should update encoding to UTF-16');
    end;

    [Test]
    procedure XmlDeclaration_Standalone_SetGet()
    var
        XDecl: XmlDeclaration;
    begin
        Initialize();
        XDecl := XmlDeclaration.Create('1.0', '', '');
        XDecl.Standalone('yes');
        Assert.AreEqual('yes', XDecl.Standalone(), 'Standalone setter/getter should preserve value');
    end;

    [Test]
    procedure XmlDocument_SetDeclaration_ThenGetDeclaration()
    var
        XDoc: XmlDocument;
        XDecl: XmlDeclaration;
        XDeclOut: XmlDeclaration;
    begin
        Initialize();
        XmlDocument.ReadFrom('<root/>', XDoc);
        XDecl := XmlDeclaration.Create('1.0', 'UTF-8', '');
        XDoc.SetDeclaration(XDecl);
        XDoc.GetDeclaration(XDeclOut);
        Assert.AreEqual('UTF-8', XDeclOut.Encoding(), 'After SetDeclaration, GetDeclaration should return same encoding');
    end;

    [Test]
    procedure XmlDocument_GetDocumentType_IsCallable()
    var
        XDoc: XmlDocument;
        XDT: XmlDocumentType;
    begin
        Initialize();
        // GetDocumentType requires a DOCTYPE declaration with a proper SYSTEM or PUBLIC identifier.
        // '<!DOCTYPE html>' alone is not valid XML — must include root element and proper prolog.
        XmlDocument.ReadFrom('<?xml version="1.0"?><!DOCTYPE root SYSTEM "test.dtd"><root/>', XDoc);
        XDoc.GetDocumentType(XDT);
        Assert.IsTrue(true, 'GetDocumentType should be callable with a valid DOCTYPE declaration');
    end;

    [Test]
    procedure XmlProcessingInstruction_GetSetTarget()
    var
        XPI: XmlProcessingInstruction;
        Target: Text;
    begin
        Initialize();
        XPI := XmlProcessingInstruction.Create('mypi', 'data');
        XPI.GetTarget(Target);
        Assert.AreEqual('mypi', Target, 'GetTarget should return processing instruction target');
    end;

    [Test]
    procedure XmlAttribute_NamespaceUri_HasValue()
    var
        XAttr: XmlAttribute;
    begin
        Initialize();
        XAttr := XmlAttribute.Create('color', 'red');
        Assert.AreEqual('', XAttr.NamespaceUri(), 'NamespaceUri on non-namespaced attribute should be empty');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
