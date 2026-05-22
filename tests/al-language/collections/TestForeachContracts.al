codeunit 60183 "Test Foreach Contracts"
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
    procedure Foreach_List_Integer_IteratesAll()
    var
        L: List of [Integer];
        Sum: Integer;
        i: Integer;
    begin
        Cleanup.Initialize();

        L.Add(1);
        L.Add(2);
        L.Add(3);
        Sum := 0;

        foreach i in L do
            Sum += i;

        Assert.AreEqual(6, Sum, 'foreach on List of [Integer] must iterate all elements (1+2+3=6)');
    end;

    [Test]
    procedure Foreach_List_Text_IteratesAll()
    var
        L: List of [Text];
        Count: Integer;
        S: Text;
    begin
        Cleanup.Initialize();

        L.Add('a');
        L.Add('b');
        L.Add('c');
        Count := 0;

        foreach S in L do
            Count += 1;

        Assert.AreEqual(3, Count, 'foreach on List of [Text] must iterate 3 elements');
    end;

    [Test]
    procedure Foreach_List_PreservesOrder()
    var
        L: List of [Integer];
        First: Integer;
        Last: Integer;
        Val: Integer;
        IsFirst: Boolean;
    begin
        Cleanup.Initialize();

        L.Add(10);
        L.Add(20);
        L.Add(30);
        L.Add(40);
        IsFirst := true;

        foreach Val in L do
        begin
            if IsFirst then
            begin
                First := Val;
                IsFirst := false;
            end;
            Last := Val;
        end;

        Assert.AreEqual(10, First, 'First foreach element must be first inserted (10)');
        Assert.AreEqual(40, Last, 'Last foreach element must be last inserted (40)');
    end;

    [Test]
    procedure Foreach_EmptyList_ZeroIterations()
    var
        L: List of [Integer];
        Count: Integer;
        i: Integer;
    begin
        Cleanup.Initialize();

        Count := 0;
        foreach i in L do
            Count += 1;

        Assert.AreEqual(0, Count, 'foreach on empty list must iterate zero times');
    end;

    [Test]
    procedure Foreach_Dictionary_Keys_IteratesAll()
    var
        D: Dictionary of [Text, Integer];
        KeyCount: Integer;
        K: Text;
    begin
        Cleanup.Initialize();

        D.Add('a', 1);
        D.Add('b', 2);
        D.Add('c', 3);
        KeyCount := 0;

        foreach K in D.Keys() do
            KeyCount += 1;

        Assert.AreEqual(3, KeyCount, 'foreach on Dictionary.Keys() must iterate all 3 keys');
    end;

    [Test]
    procedure Foreach_Dictionary_Values_SumsCorrectly()
    var
        D: Dictionary of [Text, Integer];
        Total: Integer;
        V: Integer;
    begin
        Cleanup.Initialize();

        D.Add('x', 10);
        D.Add('y', 20);
        D.Add('z', 30);
        Total := 0;

        foreach V in D.Values() do
            Total += V;

        Assert.AreEqual(60, Total, 'foreach on Dictionary.Values() must sum all values (10+20+30=60)');
    end;

        [Test]
    procedure Foreach_List_BuildsFilteredList()
    var
        Source: List of [Integer];
        Result: List of [Integer];
        N: Integer;
    begin
        Cleanup.Initialize();

        Source.Add(1);
        Source.Add(2);
        Source.Add(3);
        Source.Add(4);
        Source.Add(5);

        foreach N in Source do
            if N mod 2 = 0 then
                Result.Add(N);

        Assert.AreEqual(2, Result.Count(), 'foreach filter must find 2 even numbers (2 and 4)');
        Assert.AreEqual(2, Result.Get(1), 'First filtered element must be 2');
        Assert.AreEqual(4, Result.Get(2), 'Second filtered element must be 4');
    end;

    [Test]
    procedure Foreach_List_BreakPattern_UsingEarlyExit()
    var
        L: List of [Integer];
        Found: Integer;
        FoundAny: Boolean;
        N: Integer;
    begin
        Cleanup.Initialize();

        L.Add(10);
        L.Add(42);
        L.Add(30);
        L.Add(42);
        FoundAny := false;

        foreach N in L do
            if N = 42 then
            begin
                Found := N;
                FoundAny := true;
            end;

        Assert.IsTrue(FoundAny, 'foreach must find value 42 in the list');
        Assert.AreEqual(42, Found, 'Found must be 42');
    end;

    [Test]
    procedure Foreach_List_SumViaText_Concat()
    var
        Words: List of [Text];
        Combined: Text;
        W: Text;
    begin
        Cleanup.Initialize();

        Words.Add('Hello');
        Words.Add(' ');
        Words.Add('World');
        Combined := '';

        foreach W in Words do
            Combined += W;

        Assert.AreEqual('Hello World', Combined, 'foreach + string concat must build "Hello World"');
    end;
}
