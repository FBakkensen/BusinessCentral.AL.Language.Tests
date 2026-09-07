// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/testpage/testpagefieldtestpagefield-setvalue-method
// Scope: in-scope
// Fixtures used: ALT Temporal Row (60667), ALT Temporal Card (60668), ALT Temporal Globals (60669)
//
// What a TestPage control does with a Date, DateTime or Time.
//
// SetValue is string-typed in the AL surface, so a caller can reach a temporal control three
// ways - a typed AL variable, Format() text in the session's own format, and the ISO
// 'yyyy-mm-dd' spelling the platform's own refusal message recommends. All three land the same
// value, on a control bound to a source-table field and on a control bound to a page variable.
//
// The last two tests pin the other direction: a spelling the platform cannot evaluate is
// refused, and a Text carried in a Variant onto the field itself is refused even in the ISO
// spelling a control accepts. Without those, "accepts everything" would pass a control that
// silently ignored what it was given.

codeunit 60670 "Test TestPage Temporal Value"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    // January of the working year. Deliberately not WorkDate() itself: a fixed month and day
    // make the expected value independent of when the suite runs, and the year comes from
    // WorkDate() so the date stays inside the working period.
    local procedure TemporalSetValue_JanuaryDate(): Date
    begin
        exit(DMY2Date(15, 1, Date2DMY(WorkDate(), 3)));
    end;

    local procedure TemporalSetValue_Seed(No: Code[20]) Row: Record "ALT Temporal Row"
    begin
        Row.SetRange("No.", No);
        Row.DeleteAll();
        Row.Reset();
        Row.Init();
        Row."No." := No;
        Row.Insert();
        exit(Row);
    end;

    [Test]
    procedure TemporalSetValue_RecBoundDateControlTakesADateVariable()
    var
        Row: Record "ALT Temporal Row";
        Card: TestPage "ALT Temporal Card";
        Expected: Date;
    begin
        Row := TemporalSetValue_Seed('TSV-B');
        Expected := TemporalSetValue_JanuaryDate();

        Card.OpenEdit();
        Card.GoToRecord(Row);
        Card."The Date".SetValue(Expected);
        Card.Close();

        Row.Get('TSV-B');
        Assert.AreEqual(Expected, Row."The Date", 'Rec-bound Date control, Date variable');
    end;

    [Test]
    procedure TemporalSetValue_RecBoundDateControlTakesFormattedText()
    var
        Row: Record "ALT Temporal Row";
        Card: TestPage "ALT Temporal Card";
        Expected: Date;
    begin
        Row := TemporalSetValue_Seed('TSV-C1');
        Expected := TemporalSetValue_JanuaryDate();

        Card.OpenEdit();
        Card.GoToRecord(Row);
        Card."The Date".SetValue(Format(Expected));
        Card.Close();

        Row.Get('TSV-C1');
        Assert.AreEqual(Expected, Row."The Date", 'Rec-bound Date control, Format() text');
    end;

    [Test]
    procedure TemporalSetValue_RecBoundDateControlTakesIsoText()
    var
        Row: Record "ALT Temporal Row";
        Card: TestPage "ALT Temporal Card";
        Expected: Date;
    begin
        Row := TemporalSetValue_Seed('TSV-C2');
        Expected := TemporalSetValue_JanuaryDate();

        Card.OpenEdit();
        Card.GoToRecord(Row);
        Card."The Date".SetValue(Format(Expected, 0, '<Year4>-<Month,2>-<Day,2>'));
        Card.Close();

        Row.Get('TSV-C2');
        Assert.AreEqual(Expected, Row."The Date", 'Rec-bound Date control, ISO text');
    end;

    [Test]
    procedure TemporalSetValue_RecBoundDateTimeControlTakesADateTimeVariable()
    var
        Row: Record "ALT Temporal Row";
        Card: TestPage "ALT Temporal Card";
        Expected: DateTime;
    begin
        Row := TemporalSetValue_Seed('TSV-D');
        Expected := CreateDateTime(TemporalSetValue_JanuaryDate(), 0T);

        Card.OpenEdit();
        Card.GoToRecord(Row);
        Card."The DateTime".SetValue(Expected);
        Card.Close();

        Row.Get('TSV-D');
        Assert.AreEqual(Expected, Row."The DateTime", 'Rec-bound DateTime control, DateTime variable');
    end;

    [Test]
    procedure TemporalSetValue_RecBoundTimeControlTakesATimeVariable()
    var
        Row: Record "ALT Temporal Row";
        Card: TestPage "ALT Temporal Card";
        Expected: Time;
    begin
        Row := TemporalSetValue_Seed('TSV-E');
        Expected := 143000T;

        Card.OpenEdit();
        Card.GoToRecord(Row);
        Card."The Time".SetValue(Expected);
        Card.Close();

        Row.Get('TSV-E');
        Assert.AreEqual(Expected, Row."The Time", 'Rec-bound Time control, Time variable');
    end;

    [Test]
    procedure TemporalSetValue_PageVariableDateControlTakesADateVariable()
    var
        Globals: TestPage "ALT Temporal Globals";
        Expected: Date;
    begin
        Expected := TemporalSetValue_JanuaryDate();

        Globals.OpenEdit();
        Globals.GDate.SetValue(Expected);

        Assert.AreEqual(
            Format(Expected, 0, '<Year4>-<Month,2>-<Day,2>'), Globals.GEcho.Value(),
            'page-variable Date control, Date variable');
        Globals.Close();
    end;

    [Test]
    procedure TemporalSetValue_PageVariableDateControlTakesIsoText()
    var
        Globals: TestPage "ALT Temporal Globals";
        Expected: Date;
    begin
        Expected := TemporalSetValue_JanuaryDate();

        Globals.OpenEdit();
        Globals.GDate.SetValue(Format(Expected, 0, '<Year4>-<Month,2>-<Day,2>'));

        Assert.AreEqual(
            Format(Expected, 0, '<Year4>-<Month,2>-<Day,2>'), Globals.GEcho.Value(),
            'page-variable Date control, ISO text');
        Globals.Close();
    end;

    [Test]
    procedure TemporalSetValue_PageVariableDateTimeControlTakesADateTimeVariable()
    var
        Globals: TestPage "ALT Temporal Globals";
        Expected: DateTime;
    begin
        Expected := CreateDateTime(TemporalSetValue_JanuaryDate(), 0T);

        Globals.OpenEdit();
        Globals.GDateTime.SetValue(Expected);

        Assert.AreEqual(
            Format(Expected, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'),
            Globals.GEcho.Value(), 'page-variable DateTime control, DateTime variable');
        Globals.Close();
    end;

    [Test]
    procedure TemporalSetValue_PageVariableTimeControlTakesATimeVariable()
    var
        Globals: TestPage "ALT Temporal Globals";
        Expected: Time;
    begin
        Expected := 143000T;

        Globals.OpenEdit();
        Globals.GTime.SetValue(Expected);

        Assert.AreEqual(
            Format(Expected, 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>'), Globals.GEcho.Value(),
            'page-variable Time control, Time variable');
        Globals.Close();
    end;

    // The negative direction. Only the quoted value is asserted, not the whole message: the
    // wording around it is the platform's and varies by version, but a refusal that does not
    // name what was rejected is useless to whoever has to read it.
    [Test]
    procedure TemporalSetValue_RecBoundDateControlRefusesAnUnevaluableSpelling()
    var
        Row: Record "ALT Temporal Row";
        Card: TestPage "ALT Temporal Card";
    begin
        Row := TemporalSetValue_Seed('TSV-G');

        Card.OpenEdit();
        Card.GoToRecord(Row);
        asserterror Card."The Date".SetValue('not-a-date');

        Assert.IsTrue(
            StrPos(GetLastErrorText(), 'not-a-date') > 0,
            StrSubstNo('the refusal should name the rejected value; it said <%1>', GetLastErrorText()));
    end;

    // Not the same claim, and it is here so nobody reads the tests above as making it: a Text
    // carried in a Variant and validated straight onto the FIELD is not evaluated the way a
    // control's input is. The platform refuses it, even in the ISO spelling a control accepts.
    [Test]
    procedure TemporalSetValue_ValidateRefusesTextCarriedInAVariant()
    var
        Row: Record "ALT Temporal Row";
        AsText: Variant;
    begin
        Row.Init();
        Row."No." := 'TSV-P2';
        AsText := Format(TemporalSetValue_JanuaryDate(), 0, '<Year4>-<Month,2>-<Day,2>');

        asserterror Row.Validate("The Date", AsText);

        Assert.IsTrue(
            StrPos(GetLastErrorText(), Format(AsText)) > 0,
            StrSubstNo('the refusal should name the rejected value; it said <%1>', GetLastErrorText()));
    end;
}
