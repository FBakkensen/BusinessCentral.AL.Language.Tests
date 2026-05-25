codeunit 60182 "Test List ByRef Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    trigger OnRun()
    begin
        // Initialize and run all tests
        Cleanup.Initialize();
    end;

    [Test]
    procedure List_VarParam_CrossCodeunit_ModificationsVisible()
    var
        L: List of [Integer];
    begin
        Cleanup.Initialize();

        AppendViaVar(L);

        Assert.AreEqual(3, L.Count(), 'List passed via VAR to local procedure must be modified in caller');
        Assert.AreEqual(1, L.Get(1), 'First element must be 1');
    end;

    [Test]
    procedure List_VarParam_LocalHelper_AddsElements()
    var
        L: List of [Text];
    begin
        Cleanup.Initialize();

        AddStringsViaVar(L);

        Assert.AreEqual(2, L.Count(), 'VAR List helper must add elements visible to caller');
        Assert.AreEqual('Hello', L.Get(1), 'First element must be "Hello"');
    end;

    [Test]
    procedure List_ValueParam_SharesReference()
    var
        L: List of [Integer];
        OrigCount: Integer;
    begin
        Cleanup.Initialize();

        L.Add(1);
        L.Add(2);
        OrigCount := L.Count();

        AddToByValue(L);

        Assert.AreEqual(OrigCount + 2, L.Count(), 'List passed by value also uses reference semantics — changes ARE visible to caller');
    end;

    [Test]
    procedure List_VarParam_MixedTypes_Works()
    var
        Texts: List of [Text];
        Ints: List of [Integer];
    begin
        Cleanup.Initialize();

        AppendMixed(Texts, Ints);

        Assert.AreEqual(1, Texts.Count(), 'VAR Text list must receive 1 element');
        Assert.AreEqual(1, Ints.Count(), 'VAR Integer list must receive 1 element');
    end;

    [Test]
    procedure List_VarParam_Clear_VisibleToCaller()
    var
        L: List of [Integer];
    begin
        Cleanup.Initialize();

        L.Add(1);
        L.Add(2);
        ClearViaVar(L);

        Assert.AreEqual(0, L.Count(), 'Clear via VAR parameter must empty list from caller perspective');
    end;

    [Test]
    procedure List_VarParam_Filter_ModifiesInPlace()
    var
        L: List of [Text];
    begin
        Cleanup.Initialize();

        L.Add('apple');
        L.Add('banana');
        L.Add('apricot');
        FilterStartsWithA(L);

        Assert.AreEqual(2, L.Count(), 'Filter via VAR must reduce list to 2 elements starting with "a"');
    end;

            [Test]
    procedure List_Passed_PreservesOrder()
    var
        L: List of [Integer];
    begin
        Cleanup.Initialize();

        BuildOrderedList(L);

        Assert.AreEqual(1, L.Get(1), 'First element must be 1');
        Assert.AreEqual(2, L.Get(2), 'Second element must be 2');
        Assert.AreEqual(3, L.Get(3), 'Third element must be 3');
        Assert.AreEqual(3, L.Count(), 'List built via VAR must preserve insertion order');
    end;

    [Test]
    procedure List_VarParam_NestedCalls()
    var
        L: List of [Integer];
    begin
        Cleanup.Initialize();

        OuterCollect(L);

        Assert.IsTrue(L.Count() >= 2, 'List passed through nested VAR calls must accumulate from all levels');
    end;

    local procedure AppendViaVar(var L: List of [Integer])
    begin
        L.Add(1);
        L.Add(2);
        L.Add(3);
    end;

    local procedure AddStringsViaVar(var L: List of [Text])
    begin
        L.Add('Hello');
        L.Add('World');
    end;

    local procedure AddToByValue(L: List of [Integer])
    begin
        L.Add(99);
        L.Add(100);
    end;

    local procedure AppendMixed(var Texts: List of [Text]; var Ints: List of [Integer])
    begin
        Texts.Add('text');
        Ints.Add(42);
    end;

    local procedure ClearViaVar(var L: List of [Integer])
    begin
        Clear(L);
    end;

    local procedure FilterStartsWithA(var L: List of [Text])
    var
        Filtered: List of [Text];
        Item: Text;
    begin
        foreach Item in L do
            if Item.ToLower().StartsWith('a') then
                Filtered.Add(Item);
        L := Filtered;
    end;

        local procedure BuildOrderedList(var L: List of [Integer])
    begin
        L.Add(1);
        L.Add(2);
        L.Add(3);
    end;

    local procedure InnerCollect(var L: List of [Integer])
    begin
        L.Add(2);
        L.Add(3);
    end;

    local procedure OuterCollect(var L: List of [Integer])
    begin
        L.Add(1);
        InnerCollect(L);
    end;
}
