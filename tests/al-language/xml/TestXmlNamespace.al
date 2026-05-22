codeunit 60108 "Test XmlNamespace"
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
    procedure XmlNamespace_NamespacedElement_Parseable()
    var
        XDoc: XmlDocument;
        Ok: Boolean;
    begin
        // ACT
        Ok := XmlDocument.ReadFrom('<ns:root xmlns:ns="http://test"/>', XDoc);

        // ASSERT - Namespaced XML must be parseable
        Assert.IsTrue(Ok, 'Namespaced XML must be parseable');
    end;

    [Test]
    procedure XmlNamespace_NamespacedElement_LocalName()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<ns:root xmlns:ns="http://test"/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - LocalName must be 'root' (without prefix)
        Assert.AreEqual('root', XElem.LocalName(), 'LocalName must return "root" without namespace prefix');
    end;

    [Test]
    procedure XmlNamespace_NamespacedElement_Name()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<ns:root xmlns:ns="http://test"/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - Name may contain prefix, but must contain 'root'
        Assert.IsTrue(StrPos(XElem.Name(), 'root') > 0, 'Name must contain "root"');
    end;

    [Test]
    procedure XmlNamespace_DefaultNamespace_Parseable()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<root xmlns="http://default"/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - LocalName must be 'root' even with default namespace
        Assert.AreEqual('root', XElem.LocalName(), 'LocalName must return "root" with default namespace');
    end;

    [Test]
    procedure XmlNamespace_MultipleNamespaces_Parseable()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        XmlDocument.ReadFrom('<a:root xmlns:a="http://a" xmlns:b="http://b"><b:child/></a:root>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - LocalName must be 'root' despite multiple namespaces
        Assert.AreEqual('root', XElem.LocalName(), 'LocalName must return "root" with multiple namespaces');
    end;
}
