// TEMPORARY observation probe - not a test, and removed before this PR merges.
//
// Writing a Date into a table field through a TestPage control goes through the license's
// allowed-date interval. Three different dates have now been refused on one or more legs while
// passing on others, so which dates a tier permits is being measured here rather than guessed
// again: each candidate goes through the Rec-bound Date control, and the accepted and refused
// lists are reported by failing on purpose so the log carries them.
//
// asserterror rather than a TryFunction: a TryFunction may not write while RunTests is driving
// it ("Call to the function 'DELETEALL' is not allowed inside the call to 'RunTests' when it is
// used as a TryFunction"), and every candidate here has to reach a table field to be checked
// against the interval at all. Each iteration therefore forces a sentinel error on success, so
// asserterror always trips and the message says which of the two happened.
codeunit 60671 "ALT Temporal Interval Probe"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        SucceededTok: Label 'ALT-PROBE-ACCEPTED', Locked = true;

    [Test]
    procedure ObserveWhichDatesTheLicenseIntervalAllows()
    var
        Candidates: List of [Date];
        Candidate: Date;
        Accepted: TextBuilder;
        Refused: TextBuilder;
    begin
        Candidates.Add(20240101D);
        Candidates.Add(20240112D);
        Candidates.Add(20241201D);
        Candidates.Add(20241111D);
        Candidates.Add(20250101D);
        Candidates.Add(20260115D);
        Candidates.Add(20120115D);
        Candidates.Add(20110615D);
        Candidates.Add(20281231D);
        if WorkDate() <> 0D then
            Candidates.Add(WorkDate());
        Candidates.Add(Today);

        foreach Candidate in Candidates do begin
            asserterror WriteThenReportSuccess(Candidate);

            if GetLastErrorText() = SucceededTok then
                Append(Accepted, Candidate)
            else
                Append(Refused, Candidate);
        end;

        Error(
            'OBS accepted=[%1] refused=[%2] workdate=%3 today=%4',
            Accepted.ToText(), Refused.ToText(),
            Format(WorkDate(), 0, 9), Format(Today, 0, 9));
    end;

    local procedure Append(var Target: TextBuilder; Candidate: Date)
    begin
        if Target.Length() > 0 then
            Target.Append(',');
        Target.Append(Format(Candidate, 0, 9));
    end;

    // Writes the candidate through the control, then errors either way: with the sentinel when
    // the value landed, and with whatever the platform raised when it did not.
    local procedure WriteThenReportSuccess(Candidate: Date)
    var
        Row: Record "ALT Temporal Row";
        Card: TestPage "ALT Temporal Card";
    begin
        Row.SetRange("No.", 'PROBE');
        Row.DeleteAll();
        Row.Reset();
        Row.Init();
        Row."No." := 'PROBE';
        Row.Insert();

        Card.OpenEdit();
        Card.GoToRecord(Row);
        Card."The Date".SetValue(Candidate);
        Card.Close();

        Row.Get('PROBE');
        if Row."The Date" <> Candidate then
            Error('stored %1 instead', Format(Row."The Date", 0, 9));

        Error(SucceededTok);
    end;
}
