// Scope: in-scope

codeunit 60096 "Test Guid"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── CreateGuid() ─────────────────────────────────────────────────────────

    [Test]
    procedure Guid_CreateGuid_ReturnsNonEmpty()
    var
        G: Guid;
    begin
        Initialize();
        G := CreateGuid();
        Assert.AreNotEqual('', Format(G), 'CreateGuid must return a non-empty GUID');
    end;

    [Test]
    procedure Guid_CreateGuid_UniqueEachCall()
    var
        G1: Guid;
        G2: Guid;
    begin
        Initialize();
        G1 := CreateGuid();
        G2 := CreateGuid();
        Assert.AreNotEqual(Format(G1), Format(G2), 'CreateGuid must return different GUIDs on successive calls');
    end;

    // ── IsNullGuid() ─────────────────────────────────────────────────────────

    [Test]
    procedure Guid_EmptyGuid_IsEmpty()
    var
        G: Guid;
    begin
        Initialize();
        Assert.IsTrue(IsNullGuid(G), 'A default (zero-initialized) GUID must satisfy IsNullGuid');
    end;

    [Test]
    procedure Guid_CreateGuid_NotNullGuid()
    var
        G: Guid;
    begin
        Initialize();
        G := CreateGuid();
        Assert.IsFalse(IsNullGuid(G), 'A created GUID must not satisfy IsNullGuid');
    end;

    // ── Format() ─────────────────────────────────────────────────────────────

    [Test]
    procedure Guid_Format_ReturnsFormattedString()
    var
        G: Guid;
    begin
        Initialize();
        G := CreateGuid();
        Assert.IsTrue(StrLen(Format(G)) > 0, 'Format(GUID) must return a non-empty string');
    end;

    // ── Evaluate() ───────────────────────────────────────────────────────────

    [Test]
    procedure Guid_Evaluate_ParsesGuidString()
    var
        G1: Guid;
        G2: Guid;
    begin
        Initialize();
        G1 := CreateGuid();
        Evaluate(G2, Format(G1));
        Assert.AreEqual(Format(G1), Format(G2), 'Evaluate must parse a GUID string and match the original');
    end;

    // ── GUID comparison ──────────────────────────────────────────────────────

    [Test]
    procedure Guid_Comparison_SameGuid_Equal()
    var
        G1: Guid;
        G2: Guid;
    begin
        Initialize();
        G1 := CreateGuid();
        G2 := G1;
        Assert.AreEqual(Format(G1), Format(G2), 'Two GUIDs assigned from the same source must format identically');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
