// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/list/list-data-type
// Scope: in-scope

codeunit 60092 "Test List"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── List.Add(Value) ──────────────────────────────────────────────────────

    [Test]
    procedure List_Add_IncreasesCount()
    var
        L: List of [Integer];
    begin
        Initialize();
        L.Add(1);
        Assert.AreEqual(1, L.Count(), 'Count must be 1 after adding one item');
    end;

    [Test]
    procedure List_Add_Multiple_CountMatches()
    var
        L: List of [Integer];
    begin
        Initialize();
        L.Add(1);
        L.Add(2);
        L.Add(3);
        Assert.AreEqual(3, L.Count(), 'Count must be 3 after adding three items');
    end;

    // ── List.Contains(Value) ─────────────────────────────────────────────────

    [Test]
    procedure List_Contains_ExistingItem_ReturnsTrue()
    var
        L: List of [Integer];
    begin
        Initialize();
        L.Add(42);
        Assert.IsTrue(L.Contains(42), 'Contains must return true for an existing item');
    end;

    [Test]
    procedure List_Contains_MissingItem_ReturnsFalse()
    var
        L: List of [Integer];
    begin
        Initialize();
        L.Add(1);
        Assert.IsFalse(L.Contains(99), 'Contains must return false for a missing item');
    end;

    // ── List.Get(Index) ──────────────────────────────────────────────────────

    [Test]
    procedure List_Get_ByIndex_ReturnsValue()
    var
        L: List of [Integer];
    begin
        Initialize();
        L.Add(10);
        L.Add(20);
        Assert.AreEqual(20, L.Get(2), 'Get(2) must return 20 (1-based indexing)');
    end;

    // ── List.Remove(Value) ───────────────────────────────────────────────────

    [Test]
    procedure List_Remove_ExistingItem_DecreasesCount()
    var
        L: List of [Integer];
    begin
        Initialize();
        L.Add(1);
        L.Add(2);
        L.Remove(1);
        Assert.AreEqual(1, L.Count(), 'Count must be 1 after removing one item from a list of 2');
    end;

    // ── List.IndexOf(Value) ──────────────────────────────────────────────────

    [Test]
    procedure List_IndexOf_ExistingItem_ReturnsPosition()
    var
        L: List of [Integer];
    begin
        Initialize();
        L.Add(5);
        L.Add(10);
        Assert.AreEqual(2, L.IndexOf(10), 'IndexOf must return 2 for the second item (1-based)');
    end;

    // ── List.Set(Index, Value) ───────────────────────────────────────────────

    [Test]
    procedure List_Set_UpdatesValue()
    var
        L: List of [Text];
    begin
        Initialize();
        L.Add('old');
        L.Set(1, 'new');
        Assert.AreEqual('new', L.Get(1), 'Get(1) must return ''new'' after Set(1, ''new'')');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
