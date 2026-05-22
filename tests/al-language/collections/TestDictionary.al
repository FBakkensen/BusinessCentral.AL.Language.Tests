// Scope: in-scope

codeunit 60093 "Test Dictionary"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Dictionary.Add(Key, Value) ───────────────────────────────────────────

    [Test]
    procedure Dictionary_Add_IncreasesCount()
    var
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        D.Add('a', 1);
        Assert.AreEqual(1, D.Count(), 'Count must be 1 after adding one key-value pair');
    end;

    // ── Dictionary.Get(Key) ──────────────────────────────────────────────────

    [Test]
    procedure Dictionary_Get_ExistingKey_ReturnsValue()
    var
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        D.Add('key', 42);
        Assert.AreEqual(42, D.Get('key'), 'Get must return 42 for key ''key''');
    end;

    // ── Dictionary.ContainsKey(Key) ──────────────────────────────────────────

    [Test]
    procedure Dictionary_ContainsKey_ExistingKey_ReturnsTrue()
    var
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        D.Add('x', 1);
        Assert.IsTrue(D.ContainsKey('x'), 'ContainsKey must return true for an existing key');
    end;

    [Test]
    procedure Dictionary_ContainsKey_MissingKey_ReturnsFalse()
    var
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        Assert.IsFalse(D.ContainsKey('missing'), 'ContainsKey must return false for a missing key');
    end;

    // ── Dictionary.Set(Key, Value) ───────────────────────────────────────────

    [Test]
    procedure Dictionary_Set_UpdatesExistingKey()
    var
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        D.Add('k', 1);
        D.Set('k', 99);
        Assert.AreEqual(99, D.Get('k'), 'Get must return 99 after Set(''k'', 99)');
    end;

    // ── Dictionary.Remove(Key) ───────────────────────────────────────────────

    [Test]
    procedure Dictionary_Remove_ExistingKey_DecreasesCount()
    var
        D: Dictionary of [Text, Integer];
    begin
        Initialize();
        D.Add('a', 1);
        D.Add('b', 2);
        D.Remove('a');
        Assert.AreEqual(1, D.Count(), 'Count must be 1 after removing one key from a dictionary of 2');
    end;

    // ── Dictionary.Keys() ────────────────────────────────────────────────────

    [Test]
    procedure Dictionary_Keys_ReturnsAllKeys()
    var
        D: Dictionary of [Text, Integer];
        Keys: List of [Text];
    begin
        Initialize();
        D.Add('x', 1);
        D.Add('y', 2);
        Keys := D.Keys();
        Assert.AreEqual(2, Keys.Count(), 'Keys.Count must be 2 for a dictionary with 2 entries');
    end;

    // ── Dictionary.Values() ──────────────────────────────────────────────────

    [Test]
    procedure Dictionary_Values_ReturnsAllValues()
    var
        D: Dictionary of [Text, Integer];
        Values: List of [Integer];
    begin
        Initialize();
        D.Add('a', 10);
        D.Add('b', 20);
        Values := D.Values();
        Assert.IsTrue(Values.Contains(10), 'Values must contain 10');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
