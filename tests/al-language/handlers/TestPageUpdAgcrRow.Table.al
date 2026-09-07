// Fixture table for TestPageUpdateAgcr_Tests.al.

table 60496 "Test Page Upd Agcr Row"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; Amount; Integer) { }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }

    trigger OnModify()
    var
        Trace: Codeunit "Test Page Upd Agcr Trace";
    begin
        Trace.Append('Modify');
    end;
}
