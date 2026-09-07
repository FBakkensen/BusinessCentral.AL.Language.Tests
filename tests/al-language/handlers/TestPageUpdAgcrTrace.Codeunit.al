// Fixture for TestPageUpdateAgcr_Tests.al. A SingleInstance codeunit so the host page, the
// part page and the table's OnModify -- objects with no other way to share state -- append to
// ONE ordered trace within a test. TailAfter is what makes the trace an ordering assertion
// rather than a count: a test asks what fired AFTER a named marker, never how many times
// something fired (see the test file's header for why counts are not assertable here).

codeunit 60497 "Test Page Upd Agcr Trace"
{
    SingleInstance = true;

    var
        Trace: Text;

    procedure Append(Marker: Text)
    begin
        Trace += Marker + ';';
    end;

    procedure GetTrace(): Text
    begin
        exit(Trace);
    end;

    procedure Reset()
    begin
        Trace := '';
    end;

    // Everything appended after the FIRST occurrence of Marker. Blank when Marker never fired,
    // which a test distinguishes from "nothing followed it" by asserting the marker separately.
    procedure TailAfter(Marker: Text): Text
    var
        P: Integer;
    begin
        P := StrPos(Trace, Marker + ';');
        if P = 0 then
            exit('');
        exit(CopyStr(Trace, P + StrLen(Marker) + 1));
    end;

    procedure Contains(Marker: Text): Boolean
    begin
        exit(StrPos(Trace, Marker + ';') > 0);
    end;
}
