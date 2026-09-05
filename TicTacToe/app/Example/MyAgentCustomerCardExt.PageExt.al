namespace DefaultPublisher;

using Microsoft.Sales.Customer;
using System.Agents;

/// <summary>
/// Extends the Customer Card page to enable agent task assignment.
/// Adds an action that allows users to assign a task to an agent based on the current customer record.
/// The task is created with the customer's number and name as context, enabling the agent to process
/// customer-specific operations.
/// 
/// Tasks can be assigned in many other different ways; through events, job queues
/// </summary>
pageextension 70101 "My Agent Customer Card Ext" extends "Customer Card"
{
    actions
    {
        addlast(processing)
        {
            action(AssignAgentTask)
            {
                Caption = 'Assign Agent Task';
                ToolTip = 'Assign a task to the agent based on this customer.';
                Image = Task;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                    ExternalId: Text[2048];
                    From: Text[250];
                    MessageText: Text;
                    MessageTemplateTxt: Label 'Please process the customer with the name %1 and no. %2.', Locked = true;
                begin
                    // Select the agent to assign the task to
                    if not AgentSetup.OpenAgentLookup(Enum::"Agent Metadata Provider"::"My Agent", AgentUserSecurityId) then
                        exit;

                    if not MyAgentSetup.Get(AgentUserSecurityId) then
                        Error(SetupNotFoundErr);

                    // Populate message context with customer details
                    MessageText := StrSubstNo(MessageTemplateTxt, Rec.Name, Rec."No.");

                    // Set task properties based on customer
                    TaskTitle := CopyStr(StrSubstNo(TaskTitleLbl, Rec.Name), 1, MaxStrLen(TaskTitle));
                    From := CopyStr(UserId(), 1, MaxStrLen(From));

                    // Assign the task to the agent
                    AgentTask := MyAgent.AssignTask(AgentUserSecurityId, TaskTitle, From, MessageText);

                    AgentName := AgentCU.GetDisplayName(AgentUserSecurityId);
                    Message(TaskAssignedMsg, AgentTask.ID, AgentName, Rec.Name);
                end;
            }
        }
    }

    var
        SetupNotFoundErr: Label 'The setup could not be found for the selected agent.', Comment = 'Error message when agent setup record does not exist.';
        TaskTitleLbl: Label 'Process Customer: %1', Comment = '%1 = Customer Name';
        TaskAssignedMsg: Label 'Task %1 assigned successfully to agent %2 for customer %3.', Comment = '%1 = Task ID, %2 = Agent Name, %3 = Customer Name';
}