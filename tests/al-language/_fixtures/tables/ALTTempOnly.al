// ALTTempOnly: TableType = Temporary fixture.
// Used to prove contracts about tables that have no physical database backing.
// AutoIncrement = true on Entry No. lets us verify that DB-level sequencing
// does NOT fire for in-memory tables.
table 60025 "ALT Temp Only"
{
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Text Field"; Text[50])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
