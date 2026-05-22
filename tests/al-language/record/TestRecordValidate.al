// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-validate-method
// Scope: in-scope
// Fixtures used: ALT Triggered (60002), ALT Trigger Log (60003), ALT Universal (60000)

codeunit 60065 "Test Record Validate"
{
    Subtype = Test;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure Record_Validate_WithNewValue_SetsAndValidates()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Validate(Field: Any, NewValue: Any)');
    end;

    [Test]
    procedure Record_Validate_WithoutNewValue_ValidatesExistingValue()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Validate(Field: Any)');
    end;

    [Test]
    procedure Record_Validate_FiresOnValidateTrigger()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Validate(Field: Any, NewValue: Any)');
    end;

    [Test]
    procedure Record_Validate_InvalidValue_ThrowsError()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.Validate(Field: Any, NewValue: Any)');
    end;

    [Test]
    procedure Record_FieldError_ThrowsErrorWithDefaultMessage()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.FieldError(Field: Any)');
    end;

    [Test]
    procedure Record_FieldError_ThrowsErrorWithCustomMessage()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.FieldError(Field: Any, Text: String)');
    end;

    [Test]
    procedure Record_FieldError_ThrowsWithTextMessage()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.FieldError(Field: Any, Text: Text)');
    end;

    [Test]
    procedure Record_FieldError_ThrowsWithErrorInfo()
    begin
        Initialize();
        Assert.IsTrue(false, 'STUB — Record.FieldError(Field: Any, ErrorInfo: ErrorInfo)');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
