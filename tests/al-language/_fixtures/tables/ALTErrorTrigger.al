table 60023 "ALT Error Trigger"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Value"; Integer)
        {
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                if Rec."Should Error" then
                    Error('OnValidate error triggered');
            end;
        }
        field(3; "Should Error"; Boolean)
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

    trigger OnInsert()
    begin
        if Rec."Should Error" then
            Error('OnInsert error triggered');
    end;

    trigger OnModify()
    begin
        if Rec."Should Error" then
            Error('OnModify error triggered');
    end;

    trigger OnDelete()
    begin
        if Rec."Should Error" then
            Error('OnDelete error triggered');
    end;
}
