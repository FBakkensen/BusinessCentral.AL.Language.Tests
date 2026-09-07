// Fixture host for TestPageUpdateAgcr_Tests.al: CurrPage.Update(true) is reached from an
// ACTION rather than from a field's OnValidate. Without this arm, "Update re-runs
// OnAfterGetCurrRecord" and "the SetValue round trip re-runs it" stay indistinguishable.

page 60502 "Test Page Upd Agcr Action"
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
                field(Amount; Rec.Amount) { ApplicationArea = All; }
            }
        }
        area(FactBoxes)
        {
            part(Facts; "Test Page Upd Agcr Facts") { ApplicationArea = All; }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DoUpdate)
            {
                ApplicationArea = All;
                Caption = 'Do Update';

                trigger OnAction()
                begin
                    Trace.Append('ActionBegin');
                    CurrPage.Update(true);
                    Trace.Append('ActionEnd');
                end;
            }
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
