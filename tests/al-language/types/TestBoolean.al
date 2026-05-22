// Scope: in-scope

codeunit 60101 "Test Boolean"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Boolean default value ────────────────────────────────────────────────

    [Test]
    procedure Boolean_Default_IsFalse()
    var
        B: Boolean;
    begin
        Initialize();
        Assert.IsFalse(B, 'Boolean variable must default to false');
    end;

    // ── Boolean AND logic ────────────────────────────────────────────────────

    [Test]
    procedure Boolean_TrueAnd_True()
    begin
        Initialize();
        Assert.IsTrue(true and true, 'true AND true must be true');
    end;

    [Test]
    procedure Boolean_TrueAnd_False()
    begin
        Initialize();
        Assert.IsFalse(true and false, 'true AND false must be false');
    end;

    // ── Boolean OR logic ─────────────────────────────────────────────────────

    [Test]
    procedure Boolean_TrueOr_False()
    begin
        Initialize();
        Assert.IsTrue(true or false, 'true OR false must be true');
    end;

    // ── Boolean NOT logic ────────────────────────────────────────────────────

    [Test]
    procedure Boolean_Not_True()
    begin
        Initialize();
        Assert.IsFalse(not true, 'NOT true must be false');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
