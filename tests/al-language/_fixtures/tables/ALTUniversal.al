table 60000 "ALT Universal"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Boolean Field"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Integer Field"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "BigInteger Field"; BigInteger)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Decimal Field"; Decimal)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Text Field"; Text[100])
        {
            DataClassification = SystemMetadata;
        }
        field(7; "Code Field"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(8; "Date Field"; Date)
        {
            DataClassification = SystemMetadata;
        }
        field(9; "Time Field"; Time)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "DateTime Field"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Duration Field"; Duration)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "Guid Field"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(13; "Blob Field"; Blob)
        {
            DataClassification = SystemMetadata;
        }
        field(14; "Option Field"; Option)
        {
            OptionMembers = " ",Draft,Active,Closed;
            DataClassification = SystemMetadata;
        }
        field(15; "Status Field"; Enum "ALT Status")
        {
            DataClassification = SystemMetadata;
        }
        field(16; "Amount Field"; Decimal)
        {
            DataClassification = SystemMetadata;
        }
        field(17; "Description Field"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(18; "Name Field"; Text[50])
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
