table 60008 "ALT Blob"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Description"; Text[100])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Data"; Blob)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
