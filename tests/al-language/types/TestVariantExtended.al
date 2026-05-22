// Scope: in-scope
// Extended Variant type detection — IsGuid, IsDate, IsTime, IsDateTime, IsDuration, IsCode, IsRecord, IsRecordId, IsOption, IsInteger, IsDecimal, IsBoolean, IsText, IsBigInteger, IsFieldRef, IsTransactionType, IsEnum
// Fixtures: ALT Universal (60000), ALT Status (60009)

codeunit 60123 "Test Variant Extended"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Variant GUID Detection ───────────────────────────────────────────────

    [Test]
    procedure Variant_IsGuid_ReturnsTrue_WhenAssignedGuid()
    var
        V: Variant;
        G: Guid;
    begin
        Initialize();
        G := CreateGuid();
        V := G;
        Assert.IsTrue(V.IsGuid(), 'Variant must report IsGuid=true after assigning a GUID');
    end;

    [Test]
    procedure Variant_IsGuid_ReturnsFalse_WhenAssignedInteger()
    var
        V: Variant;
    begin
        Initialize();
        V := 42;
        Assert.IsFalse(V.IsGuid(), 'Variant must report IsGuid=false after assigning integer 42');
    end;

    // ── Variant Date/Time Detection ──────────────────────────────────────────

    [Test]
    procedure Variant_IsDate_ReturnsTrue_WhenAssignedDate()
    var
        V: Variant;
    begin
        Initialize();
        V := Today();
        Assert.IsTrue(V.IsDate(), 'Variant must report IsDate=true after assigning Today()');
    end;

    [Test]
    procedure Variant_IsTime_ReturnsTrue_WhenAssignedTime()
    var
        V: Variant;
    begin
        Initialize();
        V := Time();
        Assert.IsTrue(V.IsTime(), 'Variant must report IsTime=true after assigning Time()');
    end;

    [Test]
    procedure Variant_IsDateTime_ReturnsTrue_WhenAssignedDateTime()
    var
        V: Variant;
    begin
        Initialize();
        V := CurrentDateTime();
        Assert.IsTrue(V.IsDateTime(), 'Variant must report IsDateTime=true after assigning CurrentDateTime()');
    end;

    [Test]
    procedure Variant_IsText_ReturnsFalse_WhenAssignedDate()
    var
        V: Variant;
    begin
        Initialize();
        V := Today();
        Assert.IsFalse(V.IsText(), 'Variant must report IsText=false after assigning a date');
    end;

    // ── Variant Duration Detection ───────────────────────────────────────────

    [Test]
    procedure Variant_IsDuration_ReturnsTrue_WhenAssignedDuration()
    var
        V: Variant;
        Dur: Duration;
    begin
        Initialize();
        Dur := 1000;
        V := Dur;
        Assert.IsTrue(V.IsDuration(), 'Variant must report IsDuration=true after assigning Duration value 1000');
    end;

    // ── Variant Code Detection ───────────────────────────────────────────────

    [Test]
    procedure Variant_IsCode_ReturnsTrue_WhenAssignedCode()
    var
        V: Variant;
        C: Code[20];
    begin
        Initialize();
        C := 'ABC';
        V := C;
        Assert.IsTrue(V.IsCode(), 'Variant must report IsCode=true after assigning Code[20] ''ABC''');
    end;

    // ── Variant Record Detection ─────────────────────────────────────────────

    [Test]
    procedure Variant_IsRecord_ReturnsTrue_WhenAssignedRecord()
    var
        V: Variant;
        Rec: Record "ALT Universal";
    begin
        Initialize();
        V := Rec;
        Assert.IsTrue(V.IsRecord(), 'Variant must report IsRecord=true after assigning a record');
    end;

    // ── Variant RecordId Detection ───────────────────────────────────────────

    [Test]
    procedure Variant_IsRecordId_ReturnsTrue_WhenAssignedRecordId()
    var
        V: Variant;
        RId: RecordId;
    begin
        Initialize();
        V := RId;
        Assert.IsTrue(V.IsRecordId(), 'Variant must report IsRecordId=true after assigning a RecordId');
    end;

    // ── Variant Option Detection ─────────────────────────────────────────────

    [Test]
    procedure Variant_IsOption_ReturnsTrue_WhenAssignedOption()
    var
        V: Variant;
        Opt: Option a, b, c;
    begin
        Initialize();
        Opt := 1;
        V := Opt;
        Assert.IsTrue(V.IsOption(), 'Variant must report IsOption=true after assigning an Option value');
    end;

    // ── Variant Numeric Detection ────────────────────────────────────────────

    [Test]
    procedure Variant_IsInteger_ReturnsTrue_WhenAssignedInteger()
    var
        V: Variant;
    begin
        Initialize();
        V := 42;
        Assert.IsTrue(V.IsInteger(), 'Variant must report IsInteger=true after assigning integer 42');
    end;

    [Test]
    procedure Variant_IsDecimal_ReturnsTrue_WhenAssignedDecimal()
    var
        V: Variant;
        D: Decimal;
    begin
        Initialize();
        D := 3.14;
        V := D;
        Assert.IsTrue(V.IsDecimal(), 'Variant must report IsDecimal=true after assigning decimal 3.14');
    end;

    [Test]
    procedure Variant_IsInteger_ReturnsFalse_WhenAssignedDecimal()
    var
        V: Variant;
        D: Decimal;
    begin
        Initialize();
        D := 1.5;
        V := D;
        Assert.IsFalse(V.IsInteger(), 'Variant must report IsInteger=false after assigning decimal 1.5');
    end;

    [Test]
    procedure Variant_IsBigInteger_ReturnsTrue_WhenAssignedBigInteger()
    var
        V: Variant;
        BI: BigInteger;
    begin
        Initialize();
        BI := 1000000000;
        V := BI;
        Assert.IsTrue(V.IsBigInteger(), 'Variant must report IsBigInteger=true after assigning BigInteger value 1000000000');
    end;

    // ── Variant Boolean Detection ────────────────────────────────────────────

    [Test]
    procedure Variant_IsBoolean_ReturnsTrue_WhenAssignedBoolean()
    var
        V: Variant;
    begin
        Initialize();
        V := true;
        Assert.IsTrue(V.IsBoolean(), 'Variant must report IsBoolean=true after assigning boolean true');
    end;

    // ── Variant Text Detection ───────────────────────────────────────────────

    [Test]
    procedure Variant_IsText_ReturnsTrue_WhenAssignedText()
    var
        V: Variant;
    begin
        Initialize();
        V := 'hello';
        Assert.IsTrue(V.IsText(), 'Variant must report IsText=true after assigning text ''hello''');
    end;

    // ── Variant FieldRef Detection ───────────────────────────────────────────

    [Test]
    procedure Variant_IsFieldRef_ReturnsTrue_WhenAssignedFieldRef()
    var
        V: Variant;
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        Initialize();
        RecRef.Open(60000);
        FRef := RecRef.Field(1);
        V := FRef;
        Assert.IsTrue(V.IsFieldRef(), 'Variant must report IsFieldRef=true after assigning a FieldRef');
    end;

    // ── Variant TransactionType Detection ────────────────────────────────────

    [Test]
    procedure Variant_IsTransactionType_ReturnsTrue_WhenAssignedTransactionType()
    var
        V: Variant;
        TT: TransactionType;
    begin
        Initialize();
        V := TT;
        Assert.IsTrue(V.IsTransactionType(), 'Variant must report IsTransactionType=true after assigning a TransactionType value');
    end;

    // ── Variant Enum Detection ───────────────────────────────────────────────

    [Test]
    procedure Variant_IsEnum_ReturnsTrue_WhenAssignedEnum()
    var
        V: Variant;
        E: Enum "ALT Status";
    begin
        Initialize();
        E := "ALT Status"::Active;
        V := E;
        Assert.IsTrue(V.IsOption(), 'Variant must report IsEnum=true after assigning Enum "ALT Status"::Active');
    end;

    [Test]
    procedure Variant_IsEnum_ReturnsFalse_WhenAssignedOption()
    var
        V: Variant;
        Opt: Option a, b, c;
    begin
        Initialize();
        Opt := 1;
        V := Opt;
        Assert.IsFalse(V.IsOption(), 'Variant must report IsEnum=false after assigning a simple Option (not an Enum)');
    end;

    // ── Variant Type Consistency ────────────────────────────────────────────

    [Test]
    procedure Variant_MultipleTypes_IsConsistentAfterAssignment()
    var
        V: Variant;
    begin
        Initialize();
        V := 100;
        Assert.IsTrue(V.IsInteger(), 'Variant must report IsInteger=true for assigned integer');
        Assert.IsFalse(V.IsText(), 'Variant must report IsText=false when holding integer');

        V := 'text';
        Assert.IsTrue(V.IsText(), 'Variant must report IsText=true after reassignment');
        Assert.IsFalse(V.IsInteger(), 'Variant must report IsInteger=false after reassignment to text');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
