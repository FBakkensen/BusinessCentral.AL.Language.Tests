// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/session/session-bindsubscription-method
// Scope: in-scope (Cloud, Runtime 16.1+)
// Session event binding and subscription management
// Fixtures used: ALT Event Publisher (60014), ALT Event Subscriber (60015), ALT Trigger Log (60003)

codeunit 60138 "Test Session BindSubscription"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Session.BindSubscription ────────────────────────────────────────────

        local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
