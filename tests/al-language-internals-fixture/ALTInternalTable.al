table 61001 "ALT Internal Table"
{
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Value"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Internal Code"; Code[20])
        {
            Access = Internal;
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
