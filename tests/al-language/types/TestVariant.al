// Scope: in-scope

codeunit 60095 "Test Variant"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Variant type detection ───────────────────────────────────────────────

    [Test]
    procedure Variant_AssignInteger_IsInteger()
    var
        V: Variant;
    begin
        Initialize();
        V := 42;
        Assert.IsTrue(V.IsInteger(), 'Variant must report IsInteger=true after assigning 42');
    end;

    [Test]
    procedure Variant_AssignText_IsText()
    var
        V: Variant;
    begin
        Initialize();
        V := 'hello';
        Assert.IsTrue(V.IsText(), 'Variant must report IsText=true after assigning ''hello''');
    end;

    [Test]
    procedure Variant_AssignDecimal_IsDecimal()
    var
        V: Variant;
    begin
        Initialize();
        V := 3.14;
        Assert.IsTrue(V.IsDecimal(), 'Variant must report IsDecimal=true after assigning 3.14');
    end;

    [Test]
    procedure Variant_AssignBoolean_IsBoolean()
    var
        V: Variant;
    begin
        Initialize();
        V := true;
        Assert.IsTrue(V.IsBoolean(), 'Variant must report IsBoolean=true after assigning true');
    end;

    [Test]
    procedure Variant_AssignDate_IsDate()
    var
        V: Variant;
    begin
        Initialize();
        V := Today();
        Assert.IsTrue(V.IsDate(), 'Variant must report IsDate=true after assigning Today()');
    end;

    // ── Variant type change ──────────────────────────────────────────────────

    [Test]
    procedure Variant_TypeChange_UpdatesType()
    var
        V: Variant;
        X: Text;
    begin
        Initialize();
        V := 1;
        Assert.IsTrue(V.IsInteger(), 'Variant must report IsInteger=true after assigning 1');
        X := 'x';
        V := X;
        Assert.IsTrue(V.IsText(), 'Variant must report IsText=true after reassigning text variable');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
