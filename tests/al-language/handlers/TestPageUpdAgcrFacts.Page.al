// Fixture part page for TestPageUpdateAgcr_Tests.al. A FactBox-shaped CardPart with NO
// SourceTable: its one control is bound to a page global, and the only thing that ever writes
// that global is Refresh, which the HOST calls from its own OnAfterGetCurrRecord. Nothing links
// this part to the host's row -- no SubPageLink -- so the host's trigger re-running is the only
// route by which this part can show a newer value.

page 60498 "Test Page Upd Agcr Facts"
{
    PageType = CardPart;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(Profit; ProfitValue)
            {
                ApplicationArea = All;
                Caption = 'Profit';
                Editable = false;
            }
        }
    }

    var
        ProfitValue: Integer;

    procedure Refresh(No: Code[20])
    var
        Row: Record "Test Page Upd Agcr Row";
        Trace: Codeunit "Test Page Upd Agcr Trace";
    begin
        Trace.Append('PartRefresh');
        ProfitValue := 0;
        if Row.Get(No) then
            ProfitValue := Row.Amount;
    end;
}
