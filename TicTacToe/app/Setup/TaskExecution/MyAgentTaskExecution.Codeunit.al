namespace DefaultPublisher;

using System.Agents;
using System.Email;

/// <summary>
/// Defines the contract for executing agent tasks which includes includes additional validation,
/// user intervention suggestions, and contextual data retrieval.
/// </summary>
/// <remarks>
/// These procedures are executed in the context of the agent user and help fine-tuning
/// how agents interact with the system during task execution.
/// </remarks>
codeunit 70104 MyAgentTaskExecution implements IAgentTaskExecution
{
    Access = Internal;

    /// <summary>
    /// Analyzes the content of an agent task message and its attachments.
    /// Returns the list of annotations to be displayed for the message.
    /// Annotations whose severity is set to Error will stop the execution of the related task.
    /// Annotations whose severity is set to Warning will enforce a review of the message.
    /// </summary>
    /// <remarks>
    /// These annotations are persisted on the message. The server asks once for the message-level annotations.
    /// </remarks>
    /// <param name="AgentTaskMessage">The agent task message.</param>
    /// <param name="Annotations">The list of annotations for the message.</param>
    procedure AnalyzeAgentTaskMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    begin
        if AgentTaskMessage.Type = AgentTaskMessage.Type::Output then begin
            ValidateBoardState(Annotations);
            PostProcessOutputMessage(AgentTaskMessage, Annotations);
        end else
            ValidateInputMessage(AgentTaskMessage, Annotations);
    end;

    /// <summary>
    /// Returns all agent task user intervention suggestions applicable to the specified agent task, page, and record.
    /// </summary>
    /// <param name="AgentTaskUserInterventionRequestDetails">The agent user intervention request details.</param>
    /// <param name="Suggestions">The agent task user intervention suggestions.</param>
    procedure GetAgentTaskUserInterventionSuggestions(AgentTaskUserInterventionRequestDetails: Record "Agent User Int Request Details"; var Suggestions: Record "Agent Task User Int Suggestion")
    var
        SuggestionInstructionsLbl: Label 'Follow these steps to achieve your purpose ...', Locked = true;
        SummaryLocalizedLbl: Label 'User friendly summary of the instructions';
        DescriptionLocalizedLbl: Label 'Description of the conditions or context where the suggestion would apply. Used by the system to decide on relevance of the suggestion.';
    begin
        if AgentTaskUserInterventionRequestDetails.Type = AgentTaskUserInterventionRequestDetails.Type::Assistance then begin
            // TODO: Add suggestions for assistance
            Suggestions.Summary := SummaryLocalizedLbl;
            Suggestions.Description := DescriptionLocalizedLbl;
            Suggestions.Instructions := SuggestionInstructionsLbl;
            Suggestions.Insert();
            exit;
        end;
    end;

    /// <summary>
    /// Gets the current page context for the specified agent task, page, and record.
    /// This context is provided to the agent when interacting with the pages.
    /// </summary>
    /// <param name="AgentTaskPageContextRequest">The agent task page context request.</param>
    /// <param name="AgentTaskPageContext">The agent task page context.</param>
    procedure GetAgentTaskPageContext(AgentTaskPageContextRequest: Record "Agent Task Page Context Req."; var AgentTaskPageContext: Record "Agent Task Page Context")
    begin
        // TODO: Populate page context based on the request
        if AgentTaskPageContextRequest."Page ID" = Page::"Email Attachments" then
            AgentTaskPageContext."Currency Code" := 'USD';
    end;

    local procedure IsValidMessage(AgentTaskMessage: Record "Agent Task Message"): Boolean
    begin
        // TODO: Implement validation logic here
        exit(true);
    end;

    local procedure ValidateInputMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation"): Boolean
    var
        ErrorMessageLbl: Label 'The message content is invalid.';
        ErrorDetailsLbl: Label 'Please check the message format and try again.';
    begin
        // Validate and add annotations
        if IsValidMessage(AgentTaskMessage) then
            exit;

        // Add error or warning annotations
        // Error annotations will stop the task from being processed further.
        // Warning annotations will trigger an ask for assistance.
        // This processing will only happen once per message, before it is shown to the user.
        Annotations.Code := 'INV001';
        Annotations.Severity := Annotations.Severity::Error;
        Annotations.Message := ErrorMessageLbl;
        Annotations.Details := ErrorDetailsLbl;
        Annotations.Insert();
    end;

    local procedure PostProcessOutputMessage(var AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    var
        AgentMessage: Codeunit "Agent Message";
        OldText: Text;
    begin
        OldText := AgentMessage.GetText(AgentTaskMessage);
        AgentMessage.UpdateText(AgentTaskMessage, UpdateOutputText(OldText));
    end;

    local procedure UpdateOutputText(OldText: Text): Text
    begin
        // TODO: Add your logic here, eg. add an email signature to an email.
        exit(OldText);
    end;

    /// <summary>
    /// Checks the most recent Tic-Tac-Toe board for an invalid mark count or a status
    /// that does not match the actual pattern of marks on the board, and blocks the task
    /// with an error annotation if it finds one.
    /// </summary>
    /// <param name="Annotations">The list of annotations for the message.</param>
    local procedure ValidateBoardState(var Annotations: Record "Agent Annotation")
    var
        TTTBoard: Record "TTT Board";
        Cells: array[9] of Enum "TTT Mark";
        Winner: Enum "TTT Mark";
        XCount: Integer;
        OCount: Integer;
        InconsistentCountErr: Label 'The board has an invalid number of marks (X: %1, O: %2). X must equal O, or exceed it by exactly one, since X always moves first.', Comment = '%1 = number of X marks, %2 = number of O marks';
        UndeclaredWinErr: Label 'The cells show a winning line for %1, but Status is still ''%2'' instead of ''%1 Won''.', Comment = '%1 = X or O, %2 = current status caption';
        FalseWinErr: Label 'Status is ''%1'', but there is no winning line for %2 on the board.', Comment = '%1 = current status caption, %2 = X or O';
        MissedDrawErr: Label 'All nine cells are filled and there is no winner, but Status is still ''%1'' instead of ''Draw''.', Comment = '%1 = current status caption';
    begin
        if not TTTBoard.FindLast() then
            exit;

        GetCells(TTTBoard, Cells);
        CountMarks(Cells, XCount, OCount);
        if not ((XCount = OCount) or (XCount = OCount + 1)) then begin
            AddErrorAnnotation(Annotations, 'TTT001', StrSubstNo(InconsistentCountErr, XCount, OCount));
            exit;
        end;

        Winner := GetWinner(Cells);
        case Winner of
            Winner::X:
                if TTTBoard.Status <> TTTBoard.Status::"X Won" then
                    AddErrorAnnotation(Annotations, 'TTT002', StrSubstNo(UndeclaredWinErr, 'X', Format(TTTBoard.Status)));
            Winner::O:
                if TTTBoard.Status <> TTTBoard.Status::"O Won" then
                    AddErrorAnnotation(Annotations, 'TTT002', StrSubstNo(UndeclaredWinErr, 'O', Format(TTTBoard.Status)));
            else
                if TTTBoard.Status = TTTBoard.Status::"X Won" then
                    AddErrorAnnotation(Annotations, 'TTT003', StrSubstNo(FalseWinErr, Format(TTTBoard.Status), 'X'))
                else
                    if TTTBoard.Status = TTTBoard.Status::"O Won" then
                        AddErrorAnnotation(Annotations, 'TTT003', StrSubstNo(FalseWinErr, Format(TTTBoard.Status), 'O'))
                    else
                        if (XCount + OCount = 9) and (TTTBoard.Status <> TTTBoard.Status::Draw) then
                            AddErrorAnnotation(Annotations, 'TTT004', StrSubstNo(MissedDrawErr, Format(TTTBoard.Status)));
        end;
    end;

    local procedure GetCells(TTTBoard: Record "TTT Board"; var Cells: array[9] of Enum "TTT Mark")
    begin
        Cells[1] := TTTBoard."Cell 1";
        Cells[2] := TTTBoard."Cell 2";
        Cells[3] := TTTBoard."Cell 3";
        Cells[4] := TTTBoard."Cell 4";
        Cells[5] := TTTBoard."Cell 5";
        Cells[6] := TTTBoard."Cell 6";
        Cells[7] := TTTBoard."Cell 7";
        Cells[8] := TTTBoard."Cell 8";
        Cells[9] := TTTBoard."Cell 9";
    end;

    local procedure CountMarks(var Cells: array[9] of Enum "TTT Mark"; var XCount: Integer; var OCount: Integer)
    var
        i: Integer;
    begin
        XCount := 0;
        OCount := 0;
        for i := 1 to 9 do
            case Cells[i] of
                Cells[i]::X:
                    XCount += 1;
                Cells[i]::O:
                    OCount += 1;
            end;
    end;

    local procedure GetWinner(var Cells: array[9] of Enum "TTT Mark") Winner: Enum "TTT Mark"
    begin
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

    local procedure AddErrorAnnotation(var Annotations: Record "Agent Annotation"; AnnotationCode: Text[20]; AnnotationMessage: Text)
    begin
        Annotations.Code := AnnotationCode;
        Annotations.Severity := Annotations.Severity::Error;
        Annotations.Message := CopyStr(AnnotationMessage, 1, MaxStrLen(Annotations.Message));
        Annotations.Insert();
    end;
}