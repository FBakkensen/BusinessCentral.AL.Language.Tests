page 60016 "ALT List Page"
{
    PageType = List;
    SourceTable = "ALT Universal";
    Caption = 'ALT Universal List';
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Integer Field"; Rec."Integer Field")
                {
                    ApplicationArea = All;
                }
                field("Text Field"; Rec."Text Field")
                {
                    ApplicationArea = All;
                }
                field("Decimal Field"; Rec."Decimal Field")
                {
                    ApplicationArea = All;
                }
                field("Date Field"; Rec."Date Field")
                {
                    ApplicationArea = All;
                }
                field("Status Field"; Rec."Status Field")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestAction)
            {
                ApplicationArea = All;
                Caption = 'Test Action';
                trigger OnAction()
                begin
                    Message('Action triggered for entry %1', Rec."Entry No.");
                end;
            }
        }
    }
}
