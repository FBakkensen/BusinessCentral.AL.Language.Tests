codeunit 60105 "Test JsonValue"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure JsonValue_AsText_ReturnsText()
    var
        JVal: JsonValue;
    begin
        // Arrange
        Initialize();
        JVal.SetValue('hello');

        // Act & Assert
        Assert.AreEqual('hello', JVal.AsText(), 'JsonValue.AsText should return the text value');
    end;

    [Test]
    procedure JsonValue_AsInteger_ReturnsInteger()
    var
        JVal: JsonValue;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(42);

        // Act & Assert
        Assert.AreEqual(42, JVal.AsInteger(), 'JsonValue.AsInteger should return the integer value');
    end;

    [Test]
    procedure JsonValue_AsBoolean_True()
    var
        JVal: JsonValue;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(true);

        // Act & Assert
        Assert.IsTrue(JVal.AsBoolean(), 'JsonValue.AsBoolean should return true when set to true');
    end;

    [Test]
    procedure JsonValue_AsBoolean_False()
    var
        JVal: JsonValue;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(false);

        // Act & Assert
        Assert.IsFalse(JVal.AsBoolean(), 'JsonValue.AsBoolean should return false when set to false');
    end;

    [Test]
    procedure JsonValue_AsDecimal_ReturnsDecimal()
    var
        JVal: JsonValue;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(3.14);

        // Act & Assert
        Assert.IsTrue(JVal.AsDecimal() > 3.0, 'JsonValue.AsDecimal should return decimal value greater than 3.0');
    end;

    [Test]
    procedure JsonValue_IsNull_SetNull()
    var
        JVal: JsonValue;
    begin
        // Arrange
        Initialize();
        JVal.SetValueToNull();

        // Act & Assert
        Assert.IsTrue(JVal.IsNull(), 'JsonValue.IsNull should return true when value is set to null');
    end;

    [Test]
    procedure JsonValue_IsNull_WithValue_ReturnsFalse()
    var
        JVal: JsonValue;
    begin
        // Arrange
        Initialize();
        JVal.SetValue(1);

        // Act & Assert
        Assert.IsFalse(JVal.IsNull(), 'JsonValue.IsNull should return false when value is set to a non-null value');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
