table 60001 "ALT Composite"
{
    fields
    {
        field(1; "Key1"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Key2"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Key3"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Value1"; Text[100])
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Value2"; Decimal)
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
        key(PK; "Key1", "Key2", "Key3")
        {
            Clustered = true;
        }
    }
}

