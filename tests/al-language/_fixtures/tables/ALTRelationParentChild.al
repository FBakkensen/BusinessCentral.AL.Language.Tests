table 60028 "ALT Relation Parent"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; Blocked; Boolean)
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

table 60030 "ALT Relation Parent B"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
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

table 60029 "ALT Relation Child"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Validated Ref"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = "ALT Relation Parent"."Code";
        }
        field(3; "Unvalidated Ref"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = "ALT Relation Parent"."Code";
            ValidateTableRelation = false;
        }
        field(4; "Soft Ref"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(5; Kind; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = A,B;
        }
        field(6; "Conditional Ref"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = if (Kind = const(A)) "ALT Relation Parent"."Code" else "ALT Relation Parent B"."Code";
        }
        field(7; "Single Cond Ref"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = if (Kind = const(A)) "ALT Relation Parent"."Code";
        }
        field(8; "Filtered Ref"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = "ALT Relation Parent"."Code" where(Blocked = const(false));
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
