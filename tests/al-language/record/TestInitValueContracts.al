codeunit 60195 "Test InitValue Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    local procedure Initialize()
    var
        ErrRec: Record "ALT Init Value";
    begin
        ErrRec.DeleteAll(false);
        Cleanup.Initialize();
    end;

    [Test]
    procedure InitValue_Integer_InitSetsToInitValue()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();

        // Assert
        Assert.AreEqual(1, Rec."Status", 'After Init(), Status must equal InitValue = 1 (not 0)');
    end;

    [Test]
    procedure InitValue_Text_InitSetsToInitValue()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();

        // Assert
        Assert.AreEqual('Default', Rec."Name", 'After Init(), Name must equal InitValue = "Default" (not empty)');
    end;

    [Test]
    procedure InitValue_Boolean_InitSetsToInitValue()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();

        // Assert
        Assert.IsTrue(Rec."Active", 'After Init(), Active must equal InitValue = true (not false)');
    end;

    [Test]
    procedure InitValue_Decimal_InitSetsToInitValue()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();

        // Assert
        Assert.AreEqual(9.99, Rec."Amount", 'After Init(), Amount must equal InitValue = 9.99 (not 0)');
    end;

    [Test]
    procedure InitValue_NoInitValue_UsesLanguageDefault()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();

        // Assert
        Assert.AreEqual(0, Rec."Plain", 'Field without InitValue must default to 0 after Init()');
    end;

    [Test]
    procedure InitValue_PKField_AlwaysZeroAfterInit()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        // Set PK to a non-zero value
        Rec."Entry No." := 42;
        // Init() should reset ALL fields including the PK to their language defaults
        // (InitValue only applies to non-PK fields; PK always resets to 0)
        Rec.Init();

        // Assert
        Assert.AreEqual(0, Rec."Entry No.", 'Init() must reset PK to 0 even with value set before');
    end;

    [Test]
    procedure InitValue_OverrideAndInsert()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();
        Rec."Entry No." := 1;
        Rec.Insert();
        Rec.Get(1);

        // Assert
        Assert.AreEqual(1, Rec."Status", 'Persisted record must have Status = 1 (from InitValue)');
        Assert.AreEqual('Default', Rec."Name", 'Persisted record must have Name = "Default"');
        Assert.IsTrue(Rec."Active", 'Persisted record must have Active = true');
    end;

    [Test]
    procedure InitValue_CanBeOverridden()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();
        Rec."Entry No." := 1;
        Rec."Status" := 99;
        Rec.Insert();
        Rec.Get(1);

        // Assert
        Assert.AreEqual(99, Rec."Status", 'Status overridden to 99 must persist even though InitValue = 1');
    end;

    [Test]
    procedure InitValue_MultipleInit_ReappliesDefaults()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec."Status" := 50;
        Rec."Name" := 'changed';
        Rec.Init();

        // Assert
        Assert.AreEqual(1, Rec."Status", 'Second Init() must re-apply InitValue = 1 to Status');
        Assert.AreEqual('Default', Rec."Name", 'Second Init() must re-apply InitValue "Default" to Name');
    end;

    [Test]
    procedure InitValue_Compared_To_NoInitValue()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        Rec.Init();

        // Assert
        Assert.AreNotEqual(Rec."Status", Rec."Plain", 'InitValue field (1) must differ from no-InitValue field (0) after Init()');
    end;

    [Test]
    procedure InitValue_Insert_Without_Init()
    var
        Rec: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();

        // Act
        // WITHOUT calling Init(), insert a record
        // InitValue should NOT apply because Init() was never called
        Rec."Entry No." := 2;
        // Status is not set — using language default (0)
        Rec.Insert();
        Rec.Get(2);

        // Assert
        // Status should be 0 (the language default), NOT 1 (the InitValue)
        // because Init() was not called before Insert()
        Assert.AreEqual(0, Rec."Status", 'Without Init(), Status must be 0 (language default, NOT InitValue)');
    end;

    [Test]
    procedure InitValue_DeleteAll_ThenInit_StillApplies()
    var
        Rec: Record "ALT Init Value";
        Rec2: Record "ALT Init Value";
    begin
        // Arrange
        Initialize();
        Rec2.DeleteAll(false);

        // Act
        Rec.Init();

        // Assert
        Assert.AreEqual(1, Rec."Status", 'InitValue must apply correctly even after DeleteAll');
    end;
}
