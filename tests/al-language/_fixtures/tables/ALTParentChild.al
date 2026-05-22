table 60004 "ALT Parent"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Code"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Child Count"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("ALT Child" where("Parent Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(4; "Child Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("ALT Child".Amount where("Parent Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(5; "First Child Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("ALT Child".Code where("Parent Entry No." = field("Entry No.")));
            Editable = false;
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

table 60005 "ALT Child"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Parent Entry No."; Integer)
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
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
