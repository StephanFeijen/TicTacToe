namespace DefaultPublisher;

page 70102 "My Agent KPI"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Tic-Tac-Toe Agent Summary';
    SourceTable = "My Agent KPI";
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            cuegroup(KeyMetrics)
            {
                Caption = 'Key Performance Indicators';

                // TODO: Add fields relevant to your agent's KPIs.
                field(CustomKPI; Rec."Custom KPI")
                {
                    Caption = 'Custom KPI';
                    ToolTip = 'Specifies a custom KPI for the agent.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Populate your KPI fields with relevant data here.
        GetRelevantAgent();
    end;

    local procedure GetRelevantAgent()
    var
        UserSecurityIDFilter: Text;
    begin
        if IsNullGuid(Rec."User Security ID") then begin
            UserSecurityIDFilter := Rec.GetFilter("User Security ID");
            if not Evaluate(Rec."User Security ID", UserSecurityIDFilter) then
                Error(AgentDoesNotExistErr);
        end;

        if not Rec.Get(Rec."User Security ID") then
            Rec.Insert();
    end;

    var
        AgentDoesNotExistErr: Label 'The agent does not exist. Please check the configuration.';
}
