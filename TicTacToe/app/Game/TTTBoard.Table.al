namespace DefaultPublisher;

table 70102 "TTT Board"
{
    Access = Internal;
    Caption = 'Tic-Tac-Toe Board';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the unique identifier of the game.';
            AutoIncrement = true;
            Editable = false;
        }
        field(10; "Cell 1"; Enum "TTT Mark")
        {
            Caption = 'Cell 1';
            ToolTip = 'Specifies the mark in the top-left cell.';
        }
        field(11; "Cell 2"; Enum "TTT Mark")
        {
            Caption = 'Cell 2';
            ToolTip = 'Specifies the mark in the top-middle cell.';
        }
        field(12; "Cell 3"; Enum "TTT Mark")
        {
            Caption = 'Cell 3';
            ToolTip = 'Specifies the mark in the top-right cell.';
        }
        field(13; "Cell 4"; Enum "TTT Mark")
        {
            Caption = 'Cell 4';
            ToolTip = 'Specifies the mark in the middle-left cell.';
        }
        field(14; "Cell 5"; Enum "TTT Mark")
        {
            Caption = 'Cell 5';
            ToolTip = 'Specifies the mark in the center cell.';
        }
        field(15; "Cell 6"; Enum "TTT Mark")
        {
            Caption = 'Cell 6';
            ToolTip = 'Specifies the mark in the middle-right cell.';
        }
        field(16; "Cell 7"; Enum "TTT Mark")
        {
            Caption = 'Cell 7';
            ToolTip = 'Specifies the mark in the bottom-left cell.';
        }
        field(17; "Cell 8"; Enum "TTT Mark")
        {
            Caption = 'Cell 8';
            ToolTip = 'Specifies the mark in the bottom-middle cell.';
        }
        field(18; "Cell 9"; Enum "TTT Mark")
        {
            Caption = 'Cell 9';
            ToolTip = 'Specifies the mark in the bottom-right cell.';
        }
        field(20; "Next Player"; Enum "TTT Mark")
        {
            Caption = 'Next Player';
            ToolTip = 'Specifies which player has the next move.';
        }
        field(21; Status; Enum "TTT Game Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the current status of the game.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Next Player" = "Next Player"::None then
            "Next Player" := "Next Player"::X;
    end;

    /// <summary>
    /// Enforces that a move only ever changes a single, previously empty cell, and that the
    /// mark placed matches whose turn it was according to the record before the change.
    /// </summary>
    trigger OnModify()
    var
        ChangedCell: Integer;
        ChangedCount: Integer;
        MoveMark: Enum "TTT Mark";
        MultipleCellsErr: Label 'Only one cell can be changed per move.';
        OverwriteErr: Label 'Cell %1 already contains ''%2'' and cannot be overwritten.', Comment = '%1 = cell number, %2 = existing mark';
        WrongTurnErr: Label 'It is %1''s turn, but this move places ''%2''.', Comment = '%1 = expected player mark, %2 = mark that was placed';
    begin
        ChangedCount := CountChangedCells(ChangedCell);
        if ChangedCount = 0 then
            exit;
        if ChangedCount > 1 then
            Error(MultipleCellsErr);

        if GetCell(xRec, ChangedCell) <> GetCell(xRec, ChangedCell)::None then
            Error(OverwriteErr, ChangedCell, Format(GetCell(xRec, ChangedCell)));

        MoveMark := GetCell(Rec, ChangedCell);
        if MoveMark <> xRec."Next Player" then
            Error(WrongTurnErr, Format(xRec."Next Player"), Format(MoveMark));
    end;

    /// <summary>
    /// Places the current next player's mark in the given empty cell, switches whose turn it
    /// is, and updates Status if the move wins the game or fills the board.
    /// </summary>
    /// <param name="CellNo">The cell to play, 1-9, left-to-right, top-to-bottom.</param>
    procedure PlayMove(CellNo: Integer)
    var
        MarkToPlay: Enum "TTT Mark";
        InvalidCellErr: Label 'Cell number must be between 1 and 9.';
        GameOverErr: Label 'This game is already finished (%1).', Comment = '%1 = game status';
        CellOccupiedErr: Label 'Cell %1 already contains ''%2''.', Comment = '%1 = cell number, %2 = existing mark';
    begin
        if Status <> Status::Open then
            Error(GameOverErr, Format(Status));
        if (CellNo < 1) or (CellNo > 9) then
            Error(InvalidCellErr);
        if GetCell(Rec, CellNo) <> GetCell(Rec, CellNo)::None then
            Error(CellOccupiedErr, CellNo, Format(GetCell(Rec, CellNo)));

        MarkToPlay := "Next Player";
        SetCell(CellNo, MarkToPlay);
        "Next Player" := GetOtherMark(MarkToPlay);
        Status := DetermineStatus();
        Modify(true);
    end;

    local procedure GetCell(BoardRec: Record "TTT Board"; CellNo: Integer): Enum "TTT Mark"
    begin
        case CellNo of
            1:
                exit(BoardRec."Cell 1");
            2:
                exit(BoardRec."Cell 2");
            3:
                exit(BoardRec."Cell 3");
            4:
                exit(BoardRec."Cell 4");
            5:
                exit(BoardRec."Cell 5");
            6:
                exit(BoardRec."Cell 6");
            7:
                exit(BoardRec."Cell 7");
            8:
                exit(BoardRec."Cell 8");
            9:
                exit(BoardRec."Cell 9");
        end;
    end;

    local procedure SetCell(CellNo: Integer; Mark: Enum "TTT Mark")
    begin
        case CellNo of
            1:
                "Cell 1" := Mark;
            2:
                "Cell 2" := Mark;
            3:
                "Cell 3" := Mark;
            4:
                "Cell 4" := Mark;
            5:
                "Cell 5" := Mark;
            6:
                "Cell 6" := Mark;
            7:
                "Cell 7" := Mark;
            8:
                "Cell 8" := Mark;
            9:
                "Cell 9" := Mark;
        end;
    end;

    local procedure GetOtherMark(Mark: Enum "TTT Mark"): Enum "TTT Mark"
    begin
        case Mark of
            Mark::X:
                exit(Mark::O);
            Mark::O:
                exit(Mark::X);
        end;
    end;

    local procedure DetermineStatus(): Enum "TTT Game Status"
    var
        Winner: Enum "TTT Mark";
        i: Integer;
        FilledCount: Integer;
    begin
        Winner := GetWinner();
        case Winner of
            Winner::X:
                exit(Status::"X Won");
            Winner::O:
                exit(Status::"O Won");
        end;

        for i := 1 to 9 do
            if GetCell(Rec, i) <> GetCell(Rec, i)::None then
                FilledCount += 1;

        if FilledCount = 9 then
            exit(Status::Draw);

        exit(Status::Open);
    end;

    local procedure GetWinner() Winner: Enum "TTT Mark"
    var
        Cells: array[9] of Enum "TTT Mark";
        i: Integer;
    begin
        for i := 1 to 9 do
            Cells[i] := GetCell(Rec, i);

        if IsLine(Cells, 1, 2, 3) then exit(Cells[1]);
        if IsLine(Cells, 4, 5, 6) then exit(Cells[4]);
        if IsLine(Cells, 7, 8, 9) then exit(Cells[7]);
        if IsLine(Cells, 1, 4, 7) then exit(Cells[1]);
        if IsLine(Cells, 2, 5, 8) then exit(Cells[2]);
        if IsLine(Cells, 3, 6, 9) then exit(Cells[3]);
        if IsLine(Cells, 1, 5, 9) then exit(Cells[1]);
        if IsLine(Cells, 3, 5, 7) then exit(Cells[3]);
    end;

    local procedure IsLine(var Cells: array[9] of Enum "TTT Mark"; A: Integer; B: Integer; C: Integer): Boolean
    begin
        exit((Cells[A] <> Cells[A]::None) and (Cells[A] = Cells[B]) and (Cells[B] = Cells[C]));
    end;

    local procedure CountChangedCells(var ChangedCell: Integer): Integer
    var
        i: Integer;
        ChangedCount: Integer;
    begin
        ChangedCount := 0;
        ChangedCell := 0;
        for i := 1 to 9 do
            if GetCell(Rec, i) <> GetCell(xRec, i) then begin
                ChangedCount += 1;
                ChangedCell := i;
            end;
        exit(ChangedCount);
    end;
}
