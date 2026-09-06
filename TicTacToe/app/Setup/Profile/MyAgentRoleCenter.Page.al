namespace DefaultPublisher;

page 70103 "My Agent Role Center"
{
    PageType = RoleCenter;
    Caption = 'Tic-Tac-Toe Agent Role Center';

    layout
    {
        area(RoleCenter)
        {
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenTTTBoards)
            {
                ApplicationArea = All;
                Caption = 'Tic-Tac-Toe Boards';
                ToolTip = 'Open the list of Tic-Tac-Toe boards, to view or continue a game.';
                RunObject = page "TTT Board List";
            }
        }
    }
}
