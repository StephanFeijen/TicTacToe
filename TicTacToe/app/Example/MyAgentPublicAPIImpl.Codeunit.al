namespace DefaultPublisher;

using System.Agents;

/// <summary>
/// Internal implementation for the My Agent Public API.
/// Contains the core logic for agent operations.
/// </summary>
codeunit 70107 "My Agent Public API Impl."
{
    Access = Internal;

    procedure Deactivate(AgentUserSecurityID: Guid)
    begin
        Agent.Deactivate(AgentUserSecurityID);
    end;

    procedure IsActive(AgentUserSecurityID: Guid): Boolean
    begin
        exit(Agent.IsActive(AgentUserSecurityID));
    end;

    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; From: Text[250]; Message: Text): Record "Agent Task"
    var
        TempAttachments: Record "Agent Task File" temporary;
    begin
        exit(AssignTaskInternal(AgentUserSecurityID, TaskTitle, '', From, Message, TempAttachments));
    end;

    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; ExternalId: Text[2048]; From: Text[250]; Message: Text): Record "Agent Task"
    var
        TempAttachments: Record "Agent Task File" temporary;
    begin
        exit(AssignTaskInternal(AgentUserSecurityID, TaskTitle, ExternalId, From, Message, TempAttachments));
    end;

    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; From: Text[250]; Message: Text; var TempAttachments: Record "Agent Task File"): Record "Agent Task"
    begin
        exit(AssignTaskInternal(AgentUserSecurityID, TaskTitle, '', From, Message, TempAttachments));
    end;

    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; ExternalId: Text[2048]; From: Text[250]; Message: Text; var TempAttachments: Record "Agent Task File"): Record "Agent Task"
    begin
        exit(AssignTaskInternal(AgentUserSecurityID, TaskTitle, ExternalId, From, Message, TempAttachments));
    end;

    local procedure AssignTaskInternal(AgentUserSecurityID: Guid; TaskTitle: Text[150]; ExternalId: Text[2048]; From: Text[250]; Message: Text; var TempAttachments: Record "Agent Task File"): Record "Agent Task"
    var
        AgentTaskBuilder: Codeunit "Agent Task Builder";
    begin
        AgentTaskBuilder := AgentTaskBuilder
            .Initialize(AgentUserSecurityID, TaskTitle)
            .AddTaskMessage(From, Message);

        if ExternalId <> '' then
            AgentTaskBuilder.SetExternalId(ExternalId);

        if not TempAttachments.FindSet() then
            exit(AgentTaskBuilder.Create());

        repeat
            AgentTaskBuilder.GetTaskMessageBuilder()
                .AddAttachment(TempAttachments);
        until TempAttachments.Next() = 0;

        exit(AgentTaskBuilder.Create());
    end;

    var
        Agent: Codeunit Agent;
}
