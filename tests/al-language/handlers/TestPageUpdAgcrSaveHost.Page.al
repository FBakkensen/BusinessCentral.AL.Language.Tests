// Fixture host for TestPageUpdateAgcr_Tests.al: the field's page-level OnValidate ends in
// CurrPage.Update(true) -- save, then refresh. The three sibling hosts differ from this one in
// exactly that line: NoSave (60500) passes false, Plain (60501) calls nothing, Action (60502)
// moves the call out of OnValidate and into an action.

page 60499 "Test Page Upd Agcr Save"
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
                        CurrPage.Update(true);
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
