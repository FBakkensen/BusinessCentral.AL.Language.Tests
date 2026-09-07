// Fixture host for TestPageUpdateAgcr_Tests.al: identical to the Save host (60499) except that
// its OnValidate calls no CurrPage.Update at all. Without this arm every assertion the suite
// makes about Update re-firing the host trigger could equally be explained by SetValue itself
// re-firing it.

page 60501 "Test Page Upd Agcr Plain"
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
                        // no CurrPage.Update at all -- the control arm.
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
