// Scope: in-scope

codeunit 60094 "Test Array"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Array declaration and assignment ─────────────────────────────────────

    [Test]
    procedure Array_Declare_CanAssign()
    var
        A: array[3] of Integer;
    begin
        Initialize();
        A[1] := 10;
        Assert.AreEqual(10, A[1], 'Array element A[1] must equal 10 after assignment');
    end;

    [Test]
    procedure Array_MultipleElements_IndependentValues()
    var
        A: array[3] of Integer;
    begin
        Initialize();
        A[1] := 1;
        A[2] := 2;
        A[3] := 3;
        Assert.AreEqual(2, A[2], 'Array element A[2] must equal 2');
    end;

    // ── ArrayLen() ───────────────────────────────────────────────────────────

    [Test]
    procedure Array_ArrayLen_ReturnsSize()
    var
        A: array[5] of Integer;
    begin
        Initialize();
        Assert.AreEqual(5, ArrayLen(A), 'ArrayLen must return 5 for an array of size 5');
    end;

    // ── Array initialization ─────────────────────────────────────────────────

    [Test]
    procedure Array_Default_ZeroInitialized()
    var
        A: array[3] of Integer;
    begin
        Initialize();
        Assert.AreEqual(0, A[1], 'Integer array elements must be initialized to 0');
    end;

    [Test]
    procedure Array_Text_StoresStrings()
    var
        A: array[2] of Text[50];
    begin
        Initialize();
        A[1] := 'hello';
        Assert.AreEqual('hello', A[1], 'Array element A[1] must store and return ''hello''');
    end;

    // ── Array copy behavior ──────────────────────────────────────────────────

    [Test]
    procedure Array_Copy_IndependentCopy()
    var
        A: array[3] of Integer;
        B: array[3] of Integer;
    begin
        Initialize();
        A[1] := 5;
        B[1] := A[1]; B[2] := A[2]; B[3] := A[3];
        B[1] := 99;
        Assert.AreEqual(5, A[1], 'Original array A[1] must remain 5 after modifying copy B[1]');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
