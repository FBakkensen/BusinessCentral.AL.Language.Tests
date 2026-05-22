table 60006 "ALT Keyed"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Name"; Text[50])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Code"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Amount"; Decimal)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Date Field"; Date)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Status"; Enum "ALT Status")
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
        key(Key1; "Name", "Code")
        {
        }
        key(Key2; "Amount")
        {
        }
        key(Key3; "Date Field", "Status")
        {
        }
    }
}
