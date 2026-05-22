codeunit 60184 "Test Duration Contracts"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    trigger OnRun()
    begin
        Cleanup.Initialize();
    end;

    [Test]
    procedure Duration_OneDayIs86400000Ms()
    var
        D: Duration;
    begin
        // Arrange
        D := 86400000;

        // Act & Assert
        Assert.AreEqual(86400000, D, 'Duration of 86400000 must equal itself (1 day in ms)');
    end;

    [Test]
    procedure Duration_OneHourIs3600000Ms()
    var
        D: Duration;
    begin
        // Arrange
        D := 3600000;

        // Act & Assert
        Assert.AreEqual(3600000, D, 'Duration of 3600000 must equal itself (1 hour in ms)');
    end;

    [Test]
    procedure Duration_Add_DateTimeAndDuration()
    var
        DT: DateTime;
        D: Duration;
        DT2: DateTime;
    begin
        // Arrange
        DT := CreateDateTime(20240101D, 120000T);
        D := 3600000; // 1 hour

        // Act
        DT2 := DT + D;

        // Assert
        Assert.AreEqual(130000T, DT2Time(DT2), 'Adding 1 hour Duration to 12:00:00 must give 13:00:00');
    end;

    [Test]
    procedure Duration_Subtract_TwoDateTimes()
    var
        DT1: DateTime;
        DT2: DateTime;
        Diff: Duration;
    begin
        // Arrange
        DT1 := CreateDateTime(20240101D, 120000T);
        DT2 := CreateDateTime(20240101D, 130000T);

        // Act
        Diff := DT2 - DT1;

        // Assert
        Assert.AreEqual(3600000, Diff, 'DT2 - DT1 = 1 hour = 3600000ms Duration');
    end;

    [Test]
    procedure Duration_Default_IsZero()
    var
        D: Duration;
    begin
        // Arrange & Act
        // D is default initialized

        // Assert
        Assert.AreEqual(0, D, 'Default Duration must be 0');
    end;

    [Test]
    procedure Duration_Negative_IsValid()
    var
        D: Duration;
    begin
        // Arrange
        D := -3600000; // negative 1 hour

        // Act & Assert
        Assert.IsTrue(D < 0, 'Duration can be negative');
        Assert.AreEqual(-3600000, D, 'Negative Duration must equal -3600000');
    end;

    [Test]
    procedure Duration_Arithmetic_Multiply()
    var
        D: Duration;
    begin
        // Arrange & Act
        D := 1000 * 60; // 60 seconds in ms

        // Assert
        Assert.AreEqual(60000, D, 'Duration arithmetic: 1000 * 60 = 60000ms');
    end;

    [Test]
    procedure Duration_Format_NonEmpty()
    var
        D: Duration;
        FormattedValue: Text;
    begin
        // Arrange
        D := 3661000; // 1 hour 1 minute 1 second

        // Act
        FormattedValue := Format(D);

        // Assert
        Assert.AreNotEqual('', FormattedValue, 'Format(Duration) must return non-empty string');
    end;

    [Test]
    procedure Duration_IsGreaterThan_Zero()
    var
        D1: Duration;
        D2: Duration;
    begin
        // Arrange
        D1 := 1000;
        D2 := 2000;

        // Act & Assert
        Assert.IsTrue(D2 > D1, 'Larger Duration must compare greater');
    end;

    [Test]
    procedure Duration_DateTime_Roundtrip()
    var
        DT: DateTime;
        DT2: DateTime;
        D: Duration;
        D2: Duration;
    begin
        // Arrange
        DT := CreateDateTime(20240115D, 100000T);
        D := 7200000; // 2 hours

        // Act
        DT2 := DT + D;
        D2 := DT2 - DT;

        // Assert
        Assert.AreEqual(D, D2, 'Duration roundtrip: (DT + D) - DT must equal D');
    end;

    local procedure DT2Time(DT: DateTime): Time
    begin
        exit(DT2Time(DT));
    end;
}
