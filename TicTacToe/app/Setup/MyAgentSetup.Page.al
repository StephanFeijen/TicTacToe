// This page serves as a template for creating custom agent setup pages.
// The Agent Setup Part handles common agent configuration (name, state, access control).
// Extend this page by adding your own fields and groups for agent-specific settings.
// ------------------------------------------------------------------------------------------------

namespace DefaultPublisher;

using System.Agents;
using System.AI;

page 70100 "My Agent Setup"
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    IsPreview = true;
    Caption = 'Set up Tic-Tac-Toe agent';
    InstructionalText = 'Plays Tic-Tac-Toe as O against a human player.';
    AdditionalSearchTerms = 'Tic-Tac-Toe Agent, Agent, TTT';
    SourceTable = "My Agent Setup";
    SourceTableTemporary = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            // The Agent Setup Part provides standard agent configuration UI
            // including name, display name, state, and access control settings.
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }

            // Add your own groups and fields below.
            // Each field should set IsUpdated := true in OnValidate to enable the Update button.
            group(AdditionalConfiguration)
            {
                Caption = 'Additional Configuration';
                InstructionalText = 'Add custom settings specific to your agent implementation.';

                field(DisplayName; AgentDisplayName)
                {
                    Caption = 'Display Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the display name of the agent.';

                    trigger OnValidate()
                    begin
                        // Fields on the setup part can be updated as below.
                        AgentSetupBuffer.Validate("Display Name", AgentDisplayName);
                        AgentSetupBuffer.Modify(true);
                        IsUpdated := true;

                        CurrPage.AgentSetupPart.Page.SetAgentSetupBuffer(AgentSetupBuffer);
                        CurrPage.AgentSetupPart.Page.Update(false);
                    end;
                }

                // Replace or extend with your own fields.
                // Define corresponding fields in the "My Agent Setup" table.
                field(CustomProperty; Rec."Custom Property")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a custom property for agent-specific configuration.';

                    trigger OnValidate()
                    begin
                        IsUpdated := true;
                    end;
                }
            }
        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(OK)
            {
                Caption = 'Update';
                Enabled = IsUpdated;
                ToolTip = 'Apply the changes to the agent setup.';
            }

            systemaction(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Discards the changes and closes the setup page.';
            }
        }
    }

    trigger OnOpenPage()
    var
        MyAgentSetup: Codeunit "My Agent Setup";
        UserSecurityIDFilter: Text;
        UserSecurityID: Guid;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"My Agent Capability") then
            Error(MyAgentIsNotEnabledInCopilotCapabilitiesErr);

        UserSecurityIDFilter := Rec.GetFilter("User Security ID");
        if not Evaluate(UserSecurityID, UserSecurityIDFilter) then
            Clear(UserSecurityID);

        Rec."User Security ID" := UserSecurityID;

        CurrPage.AgentSetupPart.Page.Initialize(
            UserSecurityID,
            MyAgentSetup.GetAgentMetadataProvider(),
            MyAgentSetup.GetAgentUserName(),
            MyAgentSetup.GetDefaultDisplayName(),
            MyAgentSetup.GetAgentSummary());

        InitializePage();
        IsUpdated := CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnAfterGetRecord()
    begin
        InitializePage();
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsUpdated := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        MyAgentSetup: Codeunit "My Agent Setup";
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
        MyAgentSetup.SaveSetupRecord(Rec, AgentSetupBuffer);
        MyAgentSetup.SaveCustomProperties(Rec);
        exit(true);
    end;

    local procedure InitializePage()
    var
        MyAgentSetup: Codeunit "My Agent Setup";
    begin
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
        MyAgentSetup.InitializeSetupRecord(Rec);

        AgentDisplayName := AgentSetupBuffer."Display Name";
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    var
        AgentSetupBuffer: Record "Agent Setup Buffer";
        AzureOpenAI: Codeunit "Azure OpenAI";
        IsUpdated: Boolean;
        MyAgentIsNotEnabledInCopilotCapabilitiesErr: Label 'The Tic-Tac-Toe Agent capability is not enabled in Copilot capabilities.\\Please enable the capability before setting up the agent.';
        AgentDisplayName: Text[80];
}