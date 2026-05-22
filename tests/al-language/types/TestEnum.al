// Scope: in-scope
// Fixtures: ALT Status enum (60009): ' '(0), Draft(1), Active(2), Closed(3), Archived(4)

codeunit 60097 "Test Enum"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Enum.FromInteger() ──────────────────────────────────────────────────

    [Test]
    procedure Enum_FromInteger_ValidOrdinal_ReturnsEnum()
    var
        S: Enum "ALT Status";
    begin
        Initialize();
        S := "ALT Status".FromInteger(2);
        Assert.AreEqual("ALT Status"::Active, S, 'FromInteger(2) must return the Active enum member');
    end;

    // ── Enum.AsInteger() ────────────────────────────────────────────────────

    [Test]
    procedure Enum_Ordinal_ReturnsInteger()
    begin
        Initialize();
        Assert.AreEqual(2, "ALT Status"::Active.AsInteger(), 'Active.AsInteger() must return 2');
    end;

    [Test]
    procedure Enum_Default_IsFirstValue()
    var
        S: Enum "ALT Status";
    begin
        Initialize();
        Assert.AreEqual(0, S.AsInteger(), 'Default enum must have AsInteger() = 0 (first ordinal)');
    end;

    // ── Enum assignment ─────────────────────────────────────────────────────

    [Test]
    procedure Enum_Assign_SetsValue()
    var
        S: Enum "ALT Status";
    begin
        Initialize();
        S := "ALT Status"::Closed;
        Assert.AreEqual(3, S.AsInteger(), 'Closed.AsInteger() must return 3');
    end;

    // ── Enum comparison ─────────────────────────────────────────────────────

    [Test]
    procedure Enum_Comparison_SameValue_Equal()
    var
        S1: Enum "ALT Status";
        S2: Enum "ALT Status";
    begin
        Initialize();
        S1 := "ALT Status"::Active;
        S2 := "ALT Status"::Active;
        Assert.IsTrue(S1 = S2, 'Two enums assigned the same member must be equal');
    end;

    // ── Enum.Format() ───────────────────────────────────────────────────────

    [Test]
    procedure Enum_Format_ReturnsName()
    var
        S: Enum "ALT Status";
    begin
        Initialize();
        S := "ALT Status"::Draft;
        Assert.AreEqual('Draft', Format(S), 'Format(Draft) must return ''Draft''');
    end;

    // ── Enum.FromInteger() with out-of-range ────────────────────────────────

    [Test]
    procedure Enum_FromInteger_OutOfRange_ReturnsOrdinal()
    var
        S: Enum "ALT Status";
    begin
        Initialize();
        S := "ALT Status".FromInteger(99);
        Assert.AreEqual(99, S.AsInteger(), 'FromInteger(99) must return 99 even if out of defined range');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
