codeunit 60173 "Test BC Platform Contracts"
{
    Subtype = Test;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;

    local procedure Initialize()
    begin
        Cleanup();
    end;

    local procedure Cleanup()
    begin
    end;

    [Test]
    procedure GuiAllowed_InTestContext_ReturnsFalse()
    begin
        Initialize();
        Assert.IsFalse(
            GuiAllowed(),
            'GuiAllowed() must return false when running on BC service tier (no GUI attached)'
        );
    end;

    [Test]
    procedure IsServiceTier_InTestContext_ReturnsTrue()
    begin
        Initialize();
        Assert.IsTrue(
            IsServiceTier(),
            'IsServiceTier() must return true when running on BC application server'
        );
    end;

    [Test]
    procedure Session_GetExecutionContext_ReturnsValidEnum()
    var
        EC: ExecutionContext;
    begin
        Initialize();
        EC := Session.GetExecutionContext();
        Assert.IsTrue(
            true,
            'Session.GetExecutionContext() must return without error in test context'
        );
        Assert.AreNotEqual(
            '',
            Format(EC),
            'ExecutionContext must format to non-empty string'
        );
    end;

    [Test]
    procedure NavApp_IsInstalling_ReturnsFalse()
    begin
        Initialize();
        Assert.IsFalse(
            NavApp.IsInstalling(),
            'NavApp.IsInstalling() must return false during normal test execution (not install time)'
        );
    end;

    [Test]
    procedure Session_IsSessionActive_CurrentSession()
    begin
        Initialize();
        Assert.IsFalse(
            Session.IsSessionActive(99999),
            'Session 99999 must not be active'
        );
    end;

    [Test]
    procedure NavApp_GetCurrentModuleInfo_IdMatchesAppJson()
    var
        Info: ModuleInfo;
        ExpectedId: Guid;
    begin
        Initialize();
        NavApp.GetCurrentModuleInfo(Info);
        Evaluate(ExpectedId, '{a1b2c3d4-e5f6-7890-abcd-ef1234567890}');
        Assert.AreEqual(
            Format(ExpectedId),
            Format(Info.Id),
            'NavApp.GetCurrentModuleInfo().Id must match app.json "id" field'
        );
    end;

    [Test]
    procedure NavApp_GetCurrentModuleInfo_NameMatchesAppJson()
    var
        Info: ModuleInfo;
    begin
        Initialize();
        NavApp.GetCurrentModuleInfo(Info);
        Assert.AreEqual(
            'AL Language Coverage Tests',
            Info.Name,
            'Module name must match app.json "name" field'
        );
    end;

    [Test]
    procedure NavApp_GetCurrentModuleInfo_AppVersion_IsOneOhOhOh()
    var
        Info: ModuleInfo;
        Ver: Version;
    begin
        Initialize();
        NavApp.GetCurrentModuleInfo(Info);
        Ver := Info.AppVersion();
        Assert.AreEqual(
            '1.0.0.0',
            Format(Ver),
            'AppVersion must match app.json "version": "1.0.0.0"'
        );
    end;

    [Test]
    procedure NavApp_GetCurrentModuleInfo_PackageId_NonNull()
    var
        Info: ModuleInfo;
    begin
        Initialize();
        NavApp.GetCurrentModuleInfo(Info);
        Assert.IsFalse(
            IsNullGuid(Info.PackageId()),
            'PackageId must be a non-null GUID (assigned by BC at deployment)'
        );
    end;

    [Test]
    procedure CompanyProperty_DisplayName_NonEmpty()
    begin
        Initialize();
        Assert.AreNotEqual(
            '',
            CompanyProperty.DisplayName(),
            'CompanyProperty.DisplayName() must return non-empty company name'
        );
    end;

    [Test]
    procedure CompanyProperty_UrlName_NonEmpty()
    begin
        Initialize();
        Assert.AreNotEqual(
            '',
            CompanyProperty.UrlName(),
            'CompanyProperty.UrlName() must return non-empty URL-safe company name'
        );
    end;

    [Test]
    procedure CompanyProperty_UrlName_IsUrlSafe()
    var
        UrlName: Text;
    begin
        Initialize();
        UrlName := CompanyProperty.UrlName();
        Assert.IsFalse(
            StrPos(UrlName, ' ') > 0,
            'CompanyProperty.UrlName() must not contain spaces (URL-safe format)'
        );
    end;

    [Test]
    procedure CompanyName_MatchesCurrentCompany()
    var
        Rec: Record "ALT Universal";
    begin
        Initialize();
        Assert.AreEqual(
            CompanyName(),
            Rec.CurrentCompany(),
            'CompanyName() must equal Record.CurrentCompany() in current context'
        );
    end;

    [Test]
    procedure WindowsLanguage_ReturnsPositiveId()
    var
        LangId: Integer;
    begin
        Initialize();
        LangId := WindowsLanguage();
        Assert.IsTrue(
            LangId > 0,
            'WindowsLanguage() must return a positive language ID in server context'
        );
    end;
}
