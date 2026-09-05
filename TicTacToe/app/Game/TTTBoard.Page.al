namespace DefaultPublisher;

page 70104 "TTT Board"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    Caption = 'Tic-Tac-Toe Board';
    SourceTable = "TTT Board";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Game';

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the game.';
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
            group(Board)
            {
                Caption = 'Board';

                grid(BoardGrid)
                {
                    GridLayout = Rows;

                    group(Row1)
                    {
                        ShowCaption = false;

                        field("Cell 1"; Rec."Cell 1")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the top-left cell.';
                        }
                        field("Cell 2"; Rec."Cell 2")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the top-middle cell.';
                        }
                        field("Cell 3"; Rec."Cell 3")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the top-right cell.';
                        }
                    }
                    group(Row2)
                    {
                        ShowCaption = false;

                        field("Cell 4"; Rec."Cell 4")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the middle-left cell.';
                        }
                        field("Cell 5"; Rec."Cell 5")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the center cell.';
                        }
                        field("Cell 6"; Rec."Cell 6")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the middle-right cell.';
                        }
                    }
                    group(Row3)
                    {
                        ShowCaption = false;

                        field("Cell 7"; Rec."Cell 7")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the bottom-left cell.';
                        }
                        field("Cell 8"; Rec."Cell 8")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the bottom-middle cell.';
                        }
                        field("Cell 9"; Rec."Cell 9")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the mark in the bottom-right cell.';
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewGame)
            {
                ApplicationArea = All;
                Caption = 'New Game';
                ToolTip = 'Starts a new, empty Tic-Tac-Toe game.';
                Image = New;

                trigger OnAction()
                begin
                    StartNewGame();
                end;
            }
            action(MakeMove)
            {
                ApplicationArea = All;
                Caption = 'Make Move';
                ToolTip = 'Places the next player''s mark (see the Next Player field) in an empty cell you choose.';
                Image = Change;
                Enabled = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                var
                    TTTPlayMove: Page "TTT Play Move";
                begin
                    if TTTPlayMove.RunModal() = Action::OK then begin
                        Rec.PlayMove(TTTPlayMove.GetCellNo());
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.IsEmpty() then
            StartNewGame()
        else
            Rec.FindLast();
    end;

    local procedure StartNewGame()
    begin
        Rec.Init();
        Rec."Entry No." := 0;
        Rec.Insert(true);
        CurrPage.Update(false);
    end;
}
