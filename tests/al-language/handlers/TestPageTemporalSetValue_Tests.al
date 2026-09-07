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
//
// Two things here look over-careful and are not; both are what the BC 27.0/27.3/27.5 legs
// measured on the first run of this file.
//
//  * The Rec-bound Date arms enter WorkDate() itself, with no offset. Writing a Date into a
//    table FIELD through a control goes through the license's allowed-date interval, which on
//    those legs is the filter '??11*|??12*|??01*|??02*'. Two literals were tried against it and
//    both were refused there while passing on 28.x, so which dates a tier permits is a property
//    of that tier's license and cannot be predicted from here. WorkDate() is the one date a
//    tier vouches for itself, and the arms assert against WorkDate() so the tier's own value is
//    the expected value. A DateTime or Time field is not checked against the interval, and
//    neither is a page variable, which is why only the three Date arms ever failed.
//
//    The page-variable arms keep a literal on purpose. They are the control: they exercise the
//    same spellings with nothing session-scoped in them, so if one of THEM ever fails with the
//    interval message, what changed is where BC applies the check, not this test's input.
//
//  * The refusal assertions name the type, not the rejected value. 27.x refuses a Text carried
//    in a Variant with 'Unable to convert from ...NavText to System.DateTime.', which never
//    quotes the value; 28.x quotes it. Asserting the quoted value pinned one version's wording.

codeunit 60670 "Test TestPage Temporal Value"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    // For a page-variable control: a literal, with nothing session-scoped in it. Not used by
    // the Rec-bound Date arms - see the header for why those enter WorkDate() instead.
    local procedure TemporalSetValue_Date(): Date
    begin
        exit(20240101D);
    end;

    // For a Rec-bound Date control: the tier's own working date, which is the only date a tier
    // vouches for against its own license. Guarded, because a blank WorkDate() would make the
    // arms below assert 0D against 0D and pass without proving anything.
    local procedure TemporalSetValue_TableDate(): Date
    begin
        Assert.AreNotEqual(0D, WorkDate(), 'the tier must have a working date for these arms to mean anything');
        exit(WorkDate());
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
        Expected := TemporalSetValue_TableDate();

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
        Expected := TemporalSetValue_TableDate();

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
        Expected := TemporalSetValue_TableDate();

        Card.OpenEdit();
        Card.GoToRecord(Row);
        // Format 9 is BC's own XML/invariant rendering, yyyy-MM-dd - the spelling the
        // platform's refusal message names as the one that always works.
        Card."The Date".SetValue(Format(Expected, 0, 9));
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
        Expected := CreateDateTime(TemporalSetValue_TableDate(), 0T);

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
        Expected := TemporalSetValue_Date();

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
        Expected := TemporalSetValue_Date();

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
        Expected := CreateDateTime(TemporalSetValue_Date(), 0T);

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

    // The negative direction, and the arm that stops the nine above from passing against a
    // control that silently ignores what it is handed. The refusal must name the type it could
    // not produce; the wording around that is the platform's and differs by version, so it is
    // not asserted.
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
            StrPos(GetLastErrorText(), 'Date') > 0,
            StrSubstNo('the refusal should name the Date type; it said <%1>', GetLastErrorText()));
        Assert.AreEqual(
            0D, Row."The Date", 'a refused control write must not have reached the field');
    end;

    // 'w' is the working date, and it is the arm that decides HOW a control reads its text: no
    // general-purpose date parser accepts it under any culture, so a control that resolves it
    // is going through the platform's own date evaluator rather than a parser standing in for
    // one. Asserted against WorkDate() itself, so the tier's own value is the expected value.
    // On a page variable rather than a table field, because the resulting date is whatever the
    // tier's working date happens to be and a table field would put that through the license's
    // allowed-date interval - see the header.
    [Test]
    procedure TemporalSetValue_PageVariableDateControlTakesTheWorkingDateShorthand()
    var
        Globals: TestPage "ALT Temporal Globals";
    begin
        Globals.OpenEdit();
        Globals.GDate.SetValue('w');

        Assert.AreEqual(
            Format(WorkDate(), 0, '<Year4>-<Month,2>-<Day,2>'), Globals.GEcho.Value(),
            'page-variable Date control, the working-date shorthand');
        Globals.Close();
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
        AsText := Format(TemporalSetValue_Date(), 0, '<Year4>-<Month,2>-<Day,2>');

        asserterror Row.Validate("The Date", AsText);

        // Named type, not quoted value: 27.x says 'Unable to convert from ...NavText to
        // System.DateTime.' and never quotes the text, where 28.x quotes it.
        Assert.IsTrue(
            StrPos(GetLastErrorText(), 'Date') > 0,
            StrSubstNo('the refusal should name the Date type; it said <%1>', GetLastErrorText()));
        Assert.AreEqual(0D, Row."The Date", 'a refused Validate must leave the field blank');
    end;
}
