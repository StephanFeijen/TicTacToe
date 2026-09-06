namespace DefaultPublisher;

using System.Agents;

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
            action(AssignAgentTask)
            {
                ApplicationArea = All;
                Caption = 'Assign Agent Task';
                ToolTip = 'Assign a task to the agent to play the next move on this board.';
                Image = Task;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                var
                    MyAgentSetup: Record "My Agent Setup";
                    AgentTask: Record "Agent Task";
                    AgentSetup: Codeunit "Agent Setup";
                    AgentCU: Codeunit Agent;
                    MyAgent: Codeunit "My Agent Public API";
                    AgentUserSecurityId: Guid;
                    AgentName: Text;
                    TaskTitle: Text[150];
                    From: Text[250];
                    MessageText: Text;
                    MessageTemplateTxt: Label 'Please play the next move (as %1) on Tic-Tac-Toe board no. %2.', Locked = true;
                begin
                    // Select the agent to assign the task to
                    if not AgentSetup.OpenAgentLookup(Enum::"Agent Metadata Provider"::"My Agent", AgentUserSecurityId) then
                        exit;

                    if not MyAgentSetup.Get(AgentUserSecurityId) then
                        Error(SetupNotFoundErr);

                    // Populate message context with board details
                    MessageText := StrSubstNo(MessageTemplateTxt, Rec."Next Player", Rec."Entry No.");

                    // Set task properties based on the board
                    TaskTitle := CopyStr(StrSubstNo(TaskTitleLbl, Rec."Entry No."), 1, MaxStrLen(TaskTitle));
                    From := CopyStr(UserId(), 1, MaxStrLen(From));

                    // Assign the task to the agent
                    AgentTask := MyAgent.AssignTask(AgentUserSecurityId, TaskTitle, From, MessageText);

                    AgentName := AgentCU.GetDisplayName(AgentUserSecurityId);
                    Message(TaskAssignedMsg, AgentTask.ID, AgentName, Rec."Entry No.");
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

    var
        SetupNotFoundErr: Label 'The setup could not be found for the selected agent.', Comment = 'Error message when agent setup record does not exist.';
        TaskTitleLbl: Label 'Play Tic-Tac-Toe Board: %1', Comment = '%1 = Board Entry No.';
        TaskAssignedMsg: Label 'Task %1 assigned successfully to agent %2 for board %3.', Comment = '%1 = Task ID, %2 = Agent Name, %3 = Board Entry No.';
}
