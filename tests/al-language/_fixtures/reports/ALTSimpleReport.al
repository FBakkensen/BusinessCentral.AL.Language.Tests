report 60018 "ALT Simple Report"
{
    Caption = 'ALT Simple Report';
    UsageCategory = None;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ALTUniversal; "ALT Universal")
        {
            column(EntryNo; "Entry No.")
            {
            }
            column(IntegerField; "Integer Field")
            {
            }
            column(TextField; "Text Field")
            {
            }

            trigger OnPreDataItem()
            begin
            end;

            trigger OnAfterGetRecord()
            begin
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(FilterEntryNo; FilterEntryNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Filter Entry No.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
        end;
    }

    trigger OnPreReport()
    begin
        if FilterEntryNo <> 0 then
            ALTUniversal.SetRange("Entry No.", FilterEntryNo);
    end;

    var
        FilterEntryNo: Integer;
}
