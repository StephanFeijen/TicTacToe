namespace DefaultPublisher;

page 70106 "TTT Play Move"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Make a move';

    layout
    {
        area(Content)
        {
            field(CellNo; CellNoToPlay)
            {
                ApplicationArea = All;
                Caption = 'Cell number (1-9)';
                ToolTip = 'Specifies which empty cell to place your mark in, counting left-to-right, top-to-bottom: 1=top-left, 2=top-middle, 3=top-right, 4=middle-left, 5=center, 6=middle-right, 7=bottom-left, 8=bottom-middle, 9=bottom-right. Your mark is whatever "Next Player" currently shows.';
                MinValue = 1;
                MaxValue = 9;
            }
        }
    }

    procedure GetCellNo(): Integer
    begin
        exit(CellNoToPlay);
    end;

    var
        CellNoToPlay: Integer;
}
