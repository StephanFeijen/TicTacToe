namespace DefaultPublisher;

using System.Agents;

/// <summary>
/// TODO: Document your API
/// Public API for creating and managing "My Agent" instances and assigning tasks to them.
/// </summary>
codeunit 70106 "My Agent Public API"
{
    Access = Public;

    /// <summary>
    /// Deactivates an existing "My Agent" instance.
    /// </summary>
    /// <param name="AgentUserSecurityID">The User Security ID of the agent to deactivate.</param>
    procedure Deactivate(AgentUserSecurityID: Guid)
    begin
        MyAgentPublicAPIImpl.Deactivate(AgentUserSecurityID);
    end;

    /// <summary>
    /// Checks if the agent is currently active.
    /// </summary>
    /// <param name="AgentUserSecurityID">The User Security ID of the agent.</param>
    /// <returns>True if the agent is active, false otherwise.</returns>
    procedure IsActive(AgentUserSecurityID: Guid): Boolean
    begin
        exit(MyAgentPublicAPIImpl.IsActive(AgentUserSecurityID));
    end;

    /// <summary>
    /// Creates and assigns a new task to the agent.
    /// The task will be set to ready status and picked up for processing.
    /// </summary>
    /// <param name="AgentUserSecurityID">The User Security ID of the agent.</param>
    /// <param name="TaskTitle">The title of the task.</param>
    /// <param name="From">The sender of the task message.</param>
    /// <param name="Message">The message content for the task.</param>
    /// <returns>The created Agent Task record.</returns>
    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; From: Text[250]; Message: Text): Record "Agent Task"
    begin
        exit(MyAgentPublicAPIImpl.AssignTask(AgentUserSecurityID, TaskTitle, From, Message));
    end;

    /// <summary>
    /// Creates and assigns a new task to the agent with an external ID.
    /// The task will be set to ready status and picked up for processing.
    /// </summary>
    /// <param name="AgentUserSecurityID">The User Security ID of the agent.</param>
    /// <param name="TaskTitle">The title of the task.</param>
    /// <param name="ExternalId">The external ID for the task (used to connect to external systems).</param>
    /// <param name="From">The sender of the task message.</param>
    /// <param name="Message">The message content for the task.</param>
    /// <returns>The created Agent Task record.</returns>
    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; ExternalId: Text[2048]; From: Text[250]; Message: Text): Record "Agent Task"
    begin
        exit(MyAgentPublicAPIImpl.AssignTask(AgentUserSecurityID, TaskTitle, ExternalId, From, Message));
    end;

    /// <summary>
    /// Creates and assigns a new task to the agent with attachments.
    /// The task will be set to ready status and picked up for processing.
    /// </summary>
    /// <param name="AgentUserSecurityID">The User Security ID of the agent.</param>
    /// <param name="TaskTitle">The title of the task.</param>
    /// <param name="From">The sender of the task message.</param>
    /// <param name="Message">The message content for the task.</param>
    /// <param name="TempAttachments">The file attachments to include with the task message.</param>
    /// <returns>The created Agent Task record.</returns>
    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; From: Text[250]; Message: Text; var TempAttachments: Record "Agent Task File"): Record "Agent Task"
    begin
        exit(MyAgentPublicAPIImpl.AssignTask(AgentUserSecurityID, TaskTitle, From, Message, TempAttachments));
    end;

    /// <summary>
    /// Creates and assigns a new task to the agent with an external ID and attachments.
    /// The task will be set to ready status and picked up for processing.
    /// </summary>
    /// <param name="AgentUserSecurityID">The User Security ID of the agent.</param>
    /// <param name="TaskTitle">The title of the task.</param>
    /// <param name="ExternalId">The external ID for the task (used to connect to external systems).</param>
    /// <param name="From">The sender of the task message.</param>
    /// <param name="Message">The message content for the task.</param>
    /// <param name="TempAttachments">The file attachments to include with the task message.</param>
    /// <returns>The created Agent Task record.</returns>
    procedure AssignTask(AgentUserSecurityID: Guid; TaskTitle: Text[150]; ExternalId: Text[2048]; From: Text[250]; Message: Text; var TempAttachments: Record "Agent Task File"): Record "Agent Task"
    begin
        exit(MyAgentPublicAPIImpl.AssignTask(AgentUserSecurityID, TaskTitle, ExternalId, From, Message, TempAttachments));
    end;

    var
        MyAgentPublicAPIImpl: Codeunit "My Agent Public API Impl.";
}
