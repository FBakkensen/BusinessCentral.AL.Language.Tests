page 60017 "ALT Card Page"
{
    PageType = Card;
    SourceTable = "ALT Universal";
    Caption = 'ALT Universal Card';

    layout
    {
        area(Content)
        {
            group(General)
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
                field("Boolean Field"; Rec."Boolean Field")
                {
                    ApplicationArea = All;
                }
                field("Date Field"; Rec."Date Field")
                {
                    ApplicationArea = All;
                }
                field("Amount Field"; Rec."Amount Field")
                {
                    ApplicationArea = All;
                }
                field("Description Field"; Rec."Description Field")
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
            action(TestModalAction)
            {
                ApplicationArea = All;
                Caption = 'Modal Action';
                trigger OnAction()
                begin
                    Message('Modal action triggered for entry %1', Rec."Entry No.");
                end;
            }
        }
    }
}
