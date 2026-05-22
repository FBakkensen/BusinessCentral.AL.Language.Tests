codeunit 60130 "Test Json Remaining Getters"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ===== JsonObject remaining getters =====

        local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
