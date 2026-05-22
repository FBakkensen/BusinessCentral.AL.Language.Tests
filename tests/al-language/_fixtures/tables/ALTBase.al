table 60007 "ALT Base"
{
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
        field(5; "Status"; Enum "ALT Status")
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

tableextension 60020 "ALT Extension" extends "ALT Base"
{
    fields
    {
        field(10; "Ext Text"; Text[100])
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Ext Decimal"; Decimal)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "Ext Code"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
    }
}
