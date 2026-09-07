// Fixture host for TestPageUpdateAgcr_Tests.al: identical to the Save host (60499) except that
// its OnValidate passes false -- refresh without saving.

page 60500 "Test Page Upd Agcr NoSave"
{
    PageType = Card;
    SourceTable = "Test Page Upd Agcr Row";
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Trace.Append('ValidateBegin');
                        CurrPage.Update(false);
                        Trace.Append('ValidateEnd');
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part(Facts; "Test Page Upd Agcr Facts") { ApplicationArea = All; }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Trace.Append('HostAGCR');
        CurrPage.Facts.Page.Refresh(Rec."No.");
    end;

    var
        Trace: Codeunit "Test Page Upd Agcr Trace";
}
