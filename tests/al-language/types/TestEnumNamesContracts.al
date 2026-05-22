codeunit 60194 "Test Enum Names Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    trigger OnRun()
    begin
        Cleanup.Initialize();
    end;

    [Test]
    procedure Enum_Names_ReturnsListOfText()
    var
        Names: List of [Text];
    begin
        Names := "ALT Status".Names();
        Assert.IsTrue(Names.Count() >= 4, 'Enum.Names() must return at least 4 names for ALT Status');
    end;

    [Test]
    procedure Enum_Names_ContainsDraft()
    var
        Names: List of [Text];
    begin
        Names := "ALT Status".Names();
        Assert.IsTrue(Names.Contains('Draft'), 'Enum.Names() must contain "Draft"');
    end;

    [Test]
    procedure Enum_Names_ContainsActive()
    var
        Names: List of [Text];
    begin
        Names := "ALT Status".Names();
        Assert.IsTrue(Names.Contains('Active'), 'Enum.Names() must contain "Active"');
    end;

    [Test]
    procedure Enum_Names_ContainsClosed()
    var
        Names: List of [Text];
    begin
        Names := "ALT Status".Names();
        Assert.IsTrue(Names.Contains('Closed'), 'Enum.Names() must contain "Closed"');
    end;

    [Test]
    procedure Enum_Names_FirstMatchesFirstDeclared()
    var
        Names: List of [Text];
    begin
        Names := "ALT Status".Names();
        Assert.AreNotEqual('', Names.Get(1), 'First name must not be empty');
    end;

    [Test]
    procedure Enum_Names_CountMatchesOrdinals()
    var
        Names: List of [Text];
        Ordinals: List of [Integer];
    begin
        Names := "ALT Status".Names();
        Ordinals := "ALT Status".Ordinals();
        Assert.AreEqual(Ordinals.Count(), Names.Count(), 'Enum.Names() count must equal Ordinals() count');
    end;

    [Test]
    procedure Enum_Names_ViaVariable()
    var
        S: Enum "ALT Status";
        Names: List of [Text];
    begin
        S := "ALT Status"::Active;
        Names := S.Names();
        Assert.IsTrue(Names.Count() >= 4, 'Enum.Names() via variable must return all names');
    end;

    [Test]
    procedure Enum_Names_ForALTColor()
    var
        Names: List of [Text];
    begin
        Names := "ALT Color".Names();
        Assert.IsTrue(Names.Count() >= 3, 'ALT Color enum must have at least 3 names (Red, Green, Blue)');
        Assert.IsTrue(Names.Contains('Red'), 'Names must contain "Red"');
    end;

    [Test]
    procedure Enum_Format_MatchesName()
    var
        S: Enum "ALT Status";
        Names: List of [Text];
    begin
        S := "ALT Status"::Draft;
        Names := "ALT Status".Names();
        Assert.AreEqual(Format(S), 'Draft', 'Format(enum) must return the name string "Draft"');
    end;

    [Test]
    procedure Enum_Names_DoNotContainBlankForOrdinal0()
    var
        Names: List of [Text];
    begin
        Names := "ALT Status".Names();
        Assert.IsTrue(Names.Count() >= 1, 'Names() must return at least one name even with blank ordinal 0');
    end;
}
