// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/xmlnamespacestypexml-document/
// Scope: in-scope (XmlNamespaceManager NOT available in Cloud, but namespace handling via XmlElement methods IS available)
// Fixtures used: None
// Note: XmlNamespaceManager is OnPrem-only; this codeunit tests namespace-aware XML parsing without the manager type

codeunit 60144 "Test Xml NamespaceManager"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Namespace awareness via XmlElement methods (without XmlNamespaceManager) ──

    [Test]
    procedure XmlNamespace_NamespacedXml_ParseableWithoutManager()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        ParseOk: Boolean;
    begin
        // ARRANGE & ACT
        Initialize();
        ParseOk := XmlDocument.ReadFrom('<ns:root xmlns:ns="http://test.com"/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - Namespaced XML must be parseable without XmlNamespaceManager
        Assert.IsTrue(ParseOk, 'XmlDocument.ReadFrom must successfully parse namespaced XML');
        Assert.AreEqual('root', XElem.LocalName(), 'LocalName of namespaced element must be "root" (without prefix)');
    end;

    [Test]
    procedure XmlNamespace_NamespaceUri_AvailableOnElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        NS: Text;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<ns:root xmlns:ns="http://test.com"/>', XDoc);
        XDoc.GetRoot(XElem);
        NS := XElem.NamespaceUri();

        // ASSERT - NamespaceUri must return the declared namespace
        Assert.AreEqual('http://test.com', NS, 'XmlElement.NamespaceUri() must return "http://test.com"');
    end;

    [Test]
    procedure XmlNamespace_GetPrefixOfNamespace_OnNamespacedElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        Prefix: Text;
        HasPrefix: Boolean;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<ns:root xmlns:ns="http://prefix.test"/>', XDoc);
        XDoc.GetRoot(XElem);
        HasPrefix := XElem.GetPrefixOfNamespace('http://prefix.test', Prefix);

        // ASSERT - GetPrefixOfNamespace must find the prefix for an existing namespace
        Assert.IsTrue(HasPrefix, 'GetPrefixOfNamespace must return true for existing namespace "http://prefix.test"');
        Assert.AreEqual('ns', Prefix, 'Prefix for namespace "http://prefix.test" must be "ns"');
    end;

    [Test]
    procedure XmlNamespace_GetNamespaceOfPrefix_OnNamespacedElement()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
        NS: Text;
        HasNamespace: Boolean;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<ns:root xmlns:ns="http://ns.test"/>', XDoc);
        XDoc.GetRoot(XElem);
        HasNamespace := XElem.GetNamespaceOfPrefix('ns', NS);

        // ASSERT - GetNamespaceOfPrefix must find the namespace for an existing prefix
        Assert.IsTrue(HasNamespace, 'GetNamespaceOfPrefix must return true for existing prefix "ns"');
        Assert.AreEqual('http://ns.test', NS, 'Namespace for prefix "ns" must be "http://ns.test"');
    end;

    [Test]
    procedure XmlNamespace_DefaultNamespace_LocalNameUnchanged()
    var
        XDoc: XmlDocument;
        XElem: XmlElement;
    begin
        // ARRANGE & ACT
        Initialize();
        XmlDocument.ReadFrom('<root xmlns="http://default"/>', XDoc);
        XDoc.GetRoot(XElem);

        // ASSERT - LocalName must not include default namespace prefix
        Assert.AreEqual('root', XElem.LocalName(), 'LocalName must be "root" (unchanged by default namespace)');
        Assert.AreEqual('http://default', XElem.NamespaceUri(), 'NamespaceUri must return default namespace "http://default"');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
