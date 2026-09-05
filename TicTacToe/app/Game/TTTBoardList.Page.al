namespace DefaultPublisher;

page 70105 "TTT Board List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Tic-Tac-Toe Boards';
    SourceTable = "TTT Board";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Boards)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the game.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"TTT Board", Rec);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status of the game.';
                }
                field("Next Player"; Rec."Next Player")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which player has the next move.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Open)
            {
                ApplicationArea = All;
                Caption = 'Open';
                ToolTip = 'Open the selected Tic-Tac-Toe board to view the game or make a move.';
                Image = Open;

                trigger OnAction()
                begin
                    Page.Run(Page::"TTT Board", Rec);
                end;
            }
        }
    }
}
